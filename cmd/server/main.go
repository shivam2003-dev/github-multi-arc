package main

import (
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/shivam2003-dev/github-multi-arc/internal/httpapi"
)

var version = "development"

func main() {
	port := envOrDefault("PORT", "8080")
	staticDir := envOrDefault("STATIC_DIR", "./web")

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           httpapi.New(version, staticDir),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	slog.Info("starting multi-architecture API", "port", port, "version", version)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		slog.Error("server stopped", "error", err)
		os.Exit(1)
	}
}

func envOrDefault(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}
