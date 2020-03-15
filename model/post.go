package model

import (
	"github.com/jinzhu/gorm"
	"gopkg.in/russross/blackfriday.v2"
	"log"
	"math"
	"time"
)

type Post struct {
	gorm.Model
	Author      string
	Title       string
	Path        string
	Des         string
	Content     string
	Draft       bool
	PublishedAt *time.Time

	HTML string `gorm:"-"`
	Tags []*Tag `gorm:"-"`
}

func (Post) TableName() string {
	return "blog_posts"
}

type Archive struct {
	Time  time.Time
	Posts []Post
}

func PostGetPage(pi, ps int) ([]Post, error) {
	posts := make([]Post, 0)
	cols := []string{"id", "author", "title", "path", "des", "published_at"}
	db := DB.
		Select(cols).
		Where("draft = 0").
		Order("published_at DESC")
	if pi > 0 && ps > 0 {
		db = db.Offset(calOffset(pi, ps)).Limit(ps)
	}
	err := db.Find(&posts).Error

	if err != nil {
		return nil, err
	}
	if err = PostSetAllTags(posts); err != nil {
		return nil, err
	}
	return posts, nil
}

func PostGetPageByTid(tid uint, pi, ps int) []Post {
	var posts []Post
	db := DB.Where("draft = 0 AND id in (?)",
		DB.Model(&PostTag{}).
			Select("post_id").
			Where("tag_id = ?", tid).
			QueryExpr()).
		Order("published_at DESC")
	if pi > 0 && ps > 0 {
		db = db.Offset(calOffset(pi, ps)).Limit(ps)
	}
	if err := db.Find(&posts).Error; err != nil {
		log.Println(err)
		return nil
	}
	if err := PostSetAllTags(posts); err != nil {
		log.Println(err)
		return nil
	}
	return posts
}

func PostGetByPath(path string) *Post {
	var post Post
	if err := DB.Where("path = ? AND draft = 0", path).First(&post).Error; err != nil {
		log.Println(err)
		return nil
	}
	post.HTML = string(blackfriday.Run([]byte(post.Content)))
	PostSetTags(&post)
	return &post
}

func PostSetTags(post *Post) {
	postTags := PostTagsGetByPid(post.ID)
	tags, _ := TagGetAll()
	post.Tags = make([]*Tag, len(postTags))
	for i := 0; i < len(postTags); i++ {
		post.Tags[i] = tags[postTags[i].TagID]
	}
}

func PostSetAllTags(posts []Post) error {
	tags, err := TagGetAll()
	if err != nil {
		return err
	}

	pids := make([]uint, 0, len(posts))
	var min, max uint
	min, max = math.MaxUint32, 0
	for i := 0; i < len(posts); i++ {
		posts[i].Tags = make([]*Tag, 0, 1)
		pids = append(pids, posts[i].ID)
		if posts[i].ID < min {
			min = posts[i].ID
		}
		if posts[i].ID > max {
			max = posts[i].ID
		}
	}

	bucket := make([]*Post, max-min+1)
	for i := 0; i < len(posts); i++ {
		bucket[posts[i].ID-min] = &posts[i]
	}
	postTags := PostTagGetByPids(pids)
	for i := 0; i < len(postTags); i++ {
		bucket[postTags[i].PostID-min].Tags = append(bucket[postTags[i].PostID-min].Tags, tags[postTags[i].TagID])
	}
	return nil
}

func PostCount() (int, error) {
	var count int
	err := DB.Model(&Post{}).Where("draft = 0").Count(&count).Error
	if err != nil {
		log.Println(err)
		return 0, err
	}
	return count, nil
}

func PostGetArchives() []Archive {
	posts := make([]Post, 0)
	cols := []string{"title", "path", "published_at"}
	err := DB.
		Select(cols).
		Where("draft = 0").
		Order("published_at DESC").
		Find(&posts).Error
	if err != nil {
		log.Println(err)
		return nil
	}
	archives := []Archive{{Time: *posts[0].PublishedAt}}
	i := 0
	for j := 0; j < len(posts); j++ {
		if posts[j].PublishedAt.Year() != archives[i].Time.Year() ||
			posts[j].PublishedAt.Month() != archives[i].Time.Month() {
			archives = append(archives, Archive{Time: *posts[j].PublishedAt})
			i++
		}
		archives[i].Posts = append(archives[i].Posts, posts[j])
	}
	return archives
}

func PostGetNavMap(post *Post) map[string]string {
	nm := make(map[string]string)
	var p, n Post
	DB.Select("path, title").Where("published_at < ? AND draft = 0", post.PublishedAt).
		Order("published_at DESC").First(&p)
	nm["pp"] = p.Path
	nm["pt"] = p.Title

	DB.Select("path, title").Where("published_at > ? AND draft = 0", post.PublishedAt).
		Order("published_at ASC").First(&n)
	nm["np"] = n.Path
	nm["nt"] = n.Title
	return nm
}
