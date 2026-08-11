package httpapi

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthEndpoint(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/healthz", nil)
	recorder := httptest.NewRecorder()

	New("test", "../../web").ServeHTTP(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("expected status %d, got %d", http.StatusOK, recorder.Code)
	}
	if recorder.Body.String() != "ok\n" {
		t.Fatalf("unexpected response body %q", recorder.Body.String())
	}
}

func TestInfoEndpoint(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/api/info", nil)
	recorder := httptest.NewRecorder()

	New("test-version", "../../web").ServeHTTP(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("expected status %d, got %d", http.StatusOK, recorder.Code)
	}

	var response infoResponse
	if err := json.NewDecoder(recorder.Body).Decode(&response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if response.Version != "test-version" {
		t.Fatalf("expected test version, got %q", response.Version)
	}
	if response.Architecture == "" || response.OS == "" || response.GoVersion == "" {
		t.Fatalf("expected runtime metadata, got %+v", response)
	}
}
