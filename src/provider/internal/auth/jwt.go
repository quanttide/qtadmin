package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

type header struct {
	Alg string `json:"alg"`
	Typ string `json:"typ"`
}

func base64URLEncode(data []byte) string {
	return base64.RawURLEncoding.EncodeToString(data)
}

func base64URLDecode(s string) ([]byte, error) {
	return base64.RawURLEncoding.DecodeString(s)
}

func Sign(payload map[string]any, secret string) (string, error) {
	hdr := header{Alg: "HS256", Typ: "JWT"}
	hdrData, err := json.Marshal(hdr)
	if err != nil {
		return "", fmt.Errorf("jwt: marshal header: %w", err)
	}

	payloadData, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("jwt: marshal payload: %w", err)
	}

	encodedHeader := base64URLEncode(hdrData)
	encodedPayload := base64URLEncode(payloadData)

	signingInput := encodedHeader + "." + encodedPayload

	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(signingInput))
	signature := base64URLEncode(mac.Sum(nil))

	return signingInput + "." + signature, nil
}

func Verify(token string, secret string) (map[string]any, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return nil, fmt.Errorf("jwt: invalid token format")
	}

	signingInput := parts[0] + "." + parts[1]
	expectedSig := parts[2]

	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(signingInput))
	expectedSigBytes := base64URLEncode(mac.Sum(nil))

	if !hmac.Equal([]byte(expectedSig), []byte(expectedSigBytes)) {
		return nil, fmt.Errorf("jwt: invalid signature")
	}

	payloadData, err := base64URLDecode(parts[1])
	if err != nil {
		return nil, fmt.Errorf("jwt: decode payload: %w", err)
	}

	var claims map[string]any
	if err := json.Unmarshal(payloadData, &claims); err != nil {
		return nil, fmt.Errorf("jwt: parse claims: %w", err)
	}

	exp, ok := claims["exp"].(float64)
	if ok {
		if time.Now().Unix() > int64(exp) {
			return nil, fmt.Errorf("jwt: token expired")
		}
	}

	return claims, nil
}
