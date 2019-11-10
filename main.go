package main

import (
	"context"
	"fmt"
	"net/http"

	"github.com/drone/drone-go/plugin/webhook"
	"github.com/sirupsen/logrus"
)

var log = logrus.WithField("prefix", "downstreamer")

func main() {
	server := http.Server{
		Addr: ":9184",
		Handler: webhook.Handler(
			&obj{},
			"ovu7Yu5rie6eezae0shaGhaepooqu4Ai",
			log,
		),
	}

	log.Info("Listening on " + server.Addr)
	log.Panic(server.ListenAndServe())
}

type obj struct{}

func (o obj) Deliver(ctx context.Context, req *webhook.Request) error {
	log.WithField("user", fmt.Sprintf("%#v", req.User)).
		WithField("repo", fmt.Sprintf("%#v", req.Repo)).
		WithField("build", fmt.Sprintf("%#v", req.Build)).
		Printf("%s %s\n", req.Event, req.Action)
	return nil
}
