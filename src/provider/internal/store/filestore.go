package store

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
)

// fileStore 是 Store 的本地文件实现。
//
// 数据按集合（collection）组织，每个集合对应一个 JSON 文件:
//
//	{path}/human/employees.json
//	{path}/human/departments.json
//
// 每个 JSON 文件内容为 {"records": {"id1": {...}, "id2": {...}}}。
type fileStore struct {
	mu   sync.RWMutex
	path string
}

func newFileStore(path string) (*fileStore, error) {
	if path == "" {
		path = "data"
	}
	abs, err := filepath.Abs(path)
	if err != nil {
		return nil, fmt.Errorf("store: resolve path: %w", err)
	}
	if err := os.MkdirAll(abs, 0755); err != nil {
		return nil, fmt.Errorf("store: create dir: %w", err)
	}
	return &fileStore{path: abs}, nil
}

// collectionPath 返回集合对应的 JSON 文件路径。
// 集合名用 "/" 分隔子目录，例如 "human/employees" → {path}/human/employees.json
func (fs *fileStore) collectionPath(collection string) string {
	clean := strings.TrimSuffix(collection, ".json")
	return filepath.Join(fs.path, clean+".json")
}

// loadCollection 加载一个集合文件。文件不存在时返回空集合。
func (fs *fileStore) loadCollection(collection string) (map[string]json.RawMessage, error) {
	p := fs.collectionPath(collection)
	data, err := os.ReadFile(p)
	if err != nil {
		if os.IsNotExist(err) {
			return make(map[string]json.RawMessage), nil
		}
		return nil, fmt.Errorf("store: read %s: %w", collection, err)
	}
	var wrapper struct {
		Records map[string]json.RawMessage `json:"records"`
	}
	if err := json.Unmarshal(data, &wrapper); err != nil {
		return nil, fmt.Errorf("store: parse %s: %w", collection, err)
	}
	if wrapper.Records == nil {
		wrapper.Records = make(map[string]json.RawMessage)
	}
	return wrapper.Records, nil
}

// saveCollection 将记录集写回集合文件。
func (fs *fileStore) saveCollection(collection string, records map[string]json.RawMessage) error {
	p := fs.collectionPath(collection)
	if err := os.MkdirAll(filepath.Dir(p), 0755); err != nil {
		return fmt.Errorf("store: mkdir: %w", err)
	}
	wrapper := struct {
		Records map[string]json.RawMessage `json:"records"`
	}{Records: records}
	data, err := json.MarshalIndent(wrapper, "", "  ")
	if err != nil {
		return fmt.Errorf("store: marshal %s: %w", collection, err)
	}
	if err := os.WriteFile(p, data, 0644); err != nil {
		return fmt.Errorf("store: write %s: %w", collection, err)
	}
	return nil
}

// generateID 生成一个随机的 16 字节十六进制 ID。
func generateID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return hex.EncodeToString(b)
}

// List 返回集合中所有记录（按 ID 排序）的 JSON 数组。
func (fs *fileStore) List(collection string) ([]byte, error) {
	fs.mu.RLock()
	defer fs.mu.RUnlock()

	records, err := fs.loadCollection(collection)
	if err != nil {
		return nil, err
	}

	// 按 ID 排序输出
	ids := make([]string, 0, len(records))
	for id := range records {
		ids = append(ids, id)
	}
	sort.Strings(ids)

	items := make([]json.RawMessage, 0, len(ids))
	for _, id := range ids {
		items = append(items, records[id])
	}

	return json.Marshal(items)
}

// Get 返回集合中指定 ID 的记录。
func (fs *fileStore) Get(collection, id string) ([]byte, error) {
	fs.mu.RLock()
	defer fs.mu.RUnlock()

	records, err := fs.loadCollection(collection)
	if err != nil {
		return nil, err
	}
	rec, ok := records[id]
	if !ok {
		return nil, fmt.Errorf("store: %s/%s: not found", collection, id)
	}
	return rec, nil
}

// Create 在集合中添加新记录。data 应为 JSON 对象。
// 返回自动生成的 ID。
func (fs *fileStore) Create(collection string, data []byte) (string, error) {
	fs.mu.Lock()
	defer fs.mu.Unlock()

	records, err := fs.loadCollection(collection)
	if err != nil {
		return "", err
	}

	id := generateID()
	records[id] = json.RawMessage(data)

	if err := fs.saveCollection(collection, records); err != nil {
		return "", err
	}
	return id, nil
}

// Update 更新集合中指定 ID 的记录。
func (fs *fileStore) Update(collection, id string, data []byte) error {
	fs.mu.Lock()
	defer fs.mu.Unlock()

	records, err := fs.loadCollection(collection)
	if err != nil {
		return err
	}
	if _, ok := records[id]; !ok {
		return fmt.Errorf("store: %s/%s: not found", collection, id)
	}

	records[id] = json.RawMessage(data)
	return fs.saveCollection(collection, records)
}

// Delete 删除集合中指定 ID 的记录。
func (fs *fileStore) Delete(collection, id string) error {
	fs.mu.Lock()
	defer fs.mu.Unlock()

	records, err := fs.loadCollection(collection)
	if err != nil {
		return err
	}
	if _, ok := records[id]; !ok {
		return fmt.Errorf("store: %s/%s: not found", collection, id)
	}

	delete(records, id)
	return fs.saveCollection(collection, records)
}

// Close 释放资源。
func (fs *fileStore) Close() error {
	return nil
}
