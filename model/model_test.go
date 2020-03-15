package model

import (
	"fmt"
	"testing"
)

func TestPostGetPage(t *testing.T) {
	posts, err := PostGetPage(1, 4)
	if err != nil {
		panic(err)
	}
	fmt.Println(len(posts))
	for i := 0; i < len(posts); i++ {
		fmt.Println(posts[i])
	}
}

func TestPostTagCountGroupByTid(t *testing.T) {
	postTags := PostTagCountGroupByTid()
	fmt.Println(postTags)
}

func TestTagGetID(t *testing.T) {
	initTagsCache()
}
