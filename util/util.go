package util

import (
	"html/template"
	"time"
)

func TimeFormat(t time.Time, f string) string {
	return t.Format(f)
}

func Str2HTML(raw string) template.HTML {
	return template.HTML(raw)
}
