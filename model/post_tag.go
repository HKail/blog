package model

import (
	"log"
)

type PostTag struct {
	ID        uint
	PostID    uint
	TagID     uint
	PostCount uint

	TagValue string `gorm:"-"`
	TagName  string `gorm:"-"`
}

func (PostTag) TableName() string {
	return "blog_post_tags"
}

func PostTagsGetByPid(pid uint) []PostTag {
	var postTags []PostTag
	if err := DB.Select("tag_id").Where("post_id = ?", pid).Find(&postTags).Error; err != nil {
		log.Println(err)
	}
	return postTags
}

func PostTagGetByPids(pids []uint) []PostTag {
	var postTags []PostTag
	if err := DB.Where("post_id IN (?)", pids).Find(&postTags).Error; err != nil {
		log.Println(err)
	}
	return postTags
}

func PostTagCountGroupByTid() []PostTag {
	var postTags []PostTag
	err := DB.
		Select("tag_id, COUNT(*) as post_count").
		Where("post_id NOT IN (?)", DB.Model(&Post{}).
			Select("id").
			Where("draft = 1").
			QueryExpr()).
		Group("tag_id").
		Order("post_count DESC").
		Find(&postTags).Error
	if err != nil {
		log.Println(err)
	}
	PostTagSetName(postTags...)
	return postTags
}

func PostTagSetName(postTags ...PostTag) {
	tags, err := TagGetAll()
	if err != nil {
		log.Println(err)
		return
	}
	for i := 0; i < len(postTags); i++ {
		postTags[i].TagName = tags[postTags[i].TagID].Name
		postTags[i].TagValue = tags[postTags[i].TagID].Value
	}
}

func PostCountByTid(tid uint) int {
	var count int
	err := DB.Model(&PostTag{}).
		Where("tag_id = ? AND post_id NOT IN (?)", tid,
			DB.Model(&Post{}).
				Select("id").
				Where("draft = 1").
				QueryExpr()).
		Count(&count).Error
	if err != nil {
		log.Println(err)
		return 0
	}
	return count
}
