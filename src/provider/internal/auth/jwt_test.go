package auth

import (
	"testing"
	"time"
)

func TestSignAndVerify(t *testing.T) {
	payload := map[string]any{
		"sub": "user123",
		"exp": time.Now().Add(time.Hour).Unix(),
	}
	secret := "test-secret"

	token, err := Sign(payload, secret)
	if err != nil {
		t.Fatalf("Sign failed: %v", err)
	}

	claims, err := Verify(token, secret)
	if err != nil {
		t.Fatalf("Verify failed: %v", err)
	}

	if claims["sub"] != "user123" {
		t.Errorf("expected sub=user123, got %v", claims["sub"])
	}
}

func TestVerifyInvalidFormat(t *testing.T) {
	secret := "test-secret"

	t.Run("two parts", func(t *testing.T) {
		_, err := Verify("header.payload", secret)
		if err == nil {
			t.Error("expected error for 2-part token")
		}
	})

	t.Run("one part", func(t *testing.T) {
		_, err := Verify("onlyheader", secret)
		if err == nil {
			t.Error("expected error for 1-part token")
		}
	})

	t.Run("empty", func(t *testing.T) {
		_, err := Verify("", secret)
		if err == nil {
			t.Error("expected error for empty token")
		}
	})
}

func TestVerifyBadSignature(t *testing.T) {
	payload := map[string]any{
		"sub": "user123",
		"exp": time.Now().Add(time.Hour).Unix(),
	}
	secret := "test-secret"

	token, err := Sign(payload, secret)
	if err != nil {
		t.Fatalf("Sign failed: %v", err)
	}

	tampered := token[:len(token)-1] + string(rune(token[len(token)-1]^1))

	_, err = Verify(tampered, secret)
	if err == nil {
		t.Error("expected error for bad signature")
	}
}

func TestVerifyExpired(t *testing.T) {
	payload := map[string]any{
		"sub": "user123",
		"exp": time.Now().Add(-time.Hour).Unix(),
	}
	secret := "test-secret"

	token, err := Sign(payload, secret)
	if err != nil {
		t.Fatalf("Sign failed: %v", err)
	}

	_, err = Verify(token, secret)
	if err == nil {
		t.Error("expected error for expired token")
	}
}
