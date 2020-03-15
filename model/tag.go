package model

import (
	"github.com/jinzhu/gorm"
	"log"
)

var tags []*Tag
var htags map[string]*Tag

type Tag struct {
	gorm.Model
	Value string
	Name  string
}

func (Tag) TableName() string {
	return "blog_tags"
}

func initTagsCache() {
	var result []Tag
	err := DB.Select("id, value, name").Order("id DESC").Find(&result).Error
	if err != nil {
		log.Println(err)
		return
	}
	tags = make([]*Tag, result[0].ID+1)
	htags = make(map[string]*Tag)
	for i := 0; i < len(result); i++ {
		tags[result[i].ID] = &result[i]
		htags[result[i].Value] = &result[i]
	}
}

func TagGetAll() ([]*Tag, error) {
	if tags == nil {
		initTagsCache()
	}
	return tags, nil
}

func TagGetByValue(value string) *Tag {
	if tags == nil {
		initTagsCache()
	}
	return htags[value]
}
