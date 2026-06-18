// Package store 提供数据持久化抽象层。
//
// 支持两种驱动:
//   - "file": 本地 JSON 文件存储（开发环境）
//   - "s3":   对象存储（生产环境，待实现）
//
// 使用方式:
//
//	s, err := store.New(store.Config{
//	    Driver: "file",
//	    Path:   "data",
//	})
package store

import (
	"fmt"
	"strings"
)

// Store 是数据存储的统一接口。
type Store interface {
	// List 列出集合中的所有记录。
	List(collection string) ([]byte, error)

	// Get 获取集合中指定 ID 的记录。
	Get(collection, id string) ([]byte, error)

	// Create 在集合中创建新记录，返回分配的 ID。
	Create(collection string, data []byte) (id string, err error)

	// Update 更新集合中指定 ID 的记录。
	Update(collection, id string, data []byte) error

	// Delete 删除集合中指定 ID 的记录。
	Delete(collection, id string) error

	// Close 释放存储资源。
	Close() error
}

// Config 是存储驱动的配置。
type Config struct {
	// Driver 指定存储驱动: "file" 或 "s3"
	Driver string `json:"driver"`

	// Path 是数据存储路径:
	//   - file 驱动: 本地目录路径
	//   - s3 驱动:   bucket 名称
	Path string `json:"path"`
}

// New 根据配置创建对应的 Store 实现。
func New(cfg Config) (Store, error) {
	switch strings.ToLower(cfg.Driver) {
	case "file", "":
		return newFileStore(cfg.Path)
	case "s3":
		return nil, fmt.Errorf("s3 driver not yet implemented")
	default:
		return nil, fmt.Errorf("unknown store driver: %q", cfg.Driver)
	}
}
