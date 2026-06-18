package api

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/quanttide/qtadmin-provider/internal/model"
	"github.com/quanttide/qtadmin-provider/internal/store"
)

type BusinessHandler struct {
	store store.Store
}

func NewBusinessHandler(st store.Store) *BusinessHandler {
	return &BusinessHandler{store: st}
}

// --- QtConsult Projects ---

func (h *BusinessHandler) ListProjects(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("qtconsult/projects")
	if err != nil {
		slog.Error("list projects", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list projects", http.StatusInternalServerError)
		return
	}
	var items []model.QtConsultProject
	if err := json.Unmarshal(data, &items); err != nil {
		slog.Error("parse projects", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse projects", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, items, http.StatusOK)
}

func (h *BusinessHandler) CreateProject(w http.ResponseWriter, r *http.Request) {
	var item model.QtConsultProject
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtconsult/projects", data)
	if err != nil {
		slog.Error("create project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create project", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode project with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtconsult/projects", id, data); err != nil {
		slog.Error("persist project id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *BusinessHandler) GetProject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("qtconsult/projects", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	var item model.QtConsultProject
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse project", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) UpdateProject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var item model.QtConsultProject
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.ID = id

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtconsult/projects", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) DeleteProject(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("qtconsult/projects", id); err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *BusinessHandler) UpdateProjectStage(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	data, err := h.store.Get("qtconsult/projects", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "project not found", http.StatusNotFound)
		return
	}
	var item model.QtConsultProject
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse project", http.StatusInternalServerError)
		return
	}

	var body struct {
		Stage string `json:"stage"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.Stage = body.Stage

	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode project", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtconsult/projects", id, data); err != nil {
		WriteError(w, "INTERNAL_ERROR", "failed to update project", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

// --- QtClass Courses ---

func (h *BusinessHandler) ListCourses(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("qtclass/courses")
	if err != nil {
		slog.Error("list courses", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list courses", http.StatusInternalServerError)
		return
	}
	var items []model.QtClassCourse
	if err := json.Unmarshal(data, &items); err != nil {
		slog.Error("parse courses", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse courses", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, items, http.StatusOK)
}

func (h *BusinessHandler) CreateCourse(w http.ResponseWriter, r *http.Request) {
	var item model.QtClassCourse
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode course", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtclass/courses", data)
	if err != nil {
		slog.Error("create course", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create course", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode course with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtclass/courses", id, data); err != nil {
		slog.Error("persist course id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *BusinessHandler) GetCourse(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("qtclass/courses", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "course not found", http.StatusNotFound)
		return
	}
	var item model.QtClassCourse
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse course", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse course", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) UpdateCourse(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var item model.QtClassCourse
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.ID = id

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode course", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtclass/courses", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "course not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) DeleteCourse(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("qtclass/courses", id); err != nil {
		WriteError(w, "NOT_FOUND", "course not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *BusinessHandler) ListSchedules(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("qtclass/courses")
	if err != nil {
		slog.Error("list schedules", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list schedules", http.StatusInternalServerError)
		return
	}
	var items []model.QtClassCourse
	if err := json.Unmarshal(data, &items); err != nil {
		slog.Error("parse schedules", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse schedules", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, items, http.StatusOK)
}

func (h *BusinessHandler) CreateEnrollment(w http.ResponseWriter, r *http.Request) {
	var body struct {
		CourseID string `json:"course_id"`
		Student  string `json:"student"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if body.CourseID == "" || body.Student == "" {
		WriteError(w, "VALIDATION_ERROR", "course_id and student are required", http.StatusBadRequest)
		return
	}
	WriteJSON(w, body, http.StatusCreated)
}

// --- QtCloud Resources ---

func (h *BusinessHandler) ListResources(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("qtcloud/resources")
	if err != nil {
		slog.Error("list resources", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list resources", http.StatusInternalServerError)
		return
	}
	var items []model.QtCloudResource
	if err := json.Unmarshal(data, &items); err != nil {
		slog.Error("parse resources", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse resources", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, items, http.StatusOK)
}

func (h *BusinessHandler) CreateResource(w http.ResponseWriter, r *http.Request) {
	var item model.QtCloudResource
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode resource", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtcloud/resources", data)
	if err != nil {
		slog.Error("create resource", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create resource", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode resource with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtcloud/resources", id, data); err != nil {
		slog.Error("persist resource id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *BusinessHandler) GetResource(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("qtcloud/resources", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "resource not found", http.StatusNotFound)
		return
	}
	var item model.QtCloudResource
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse resource", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse resource", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) UpdateResource(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var item model.QtCloudResource
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.ID = id

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode resource", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtcloud/resources", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "resource not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) DeleteResource(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("qtcloud/resources", id); err != nil {
		WriteError(w, "NOT_FOUND", "resource not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *BusinessHandler) UpdateResourceStatus(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	data, err := h.store.Get("qtcloud/resources", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "resource not found", http.StatusNotFound)
		return
	}
	var item model.QtCloudResource
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse resource", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse resource", http.StatusInternalServerError)
		return
	}

	var body struct {
		Status string `json:"status"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.Status = body.Status

	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode resource", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtcloud/resources", id, data); err != nil {
		WriteError(w, "INTERNAL_ERROR", "failed to update resource", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

// --- QtData Datasets ---

func (h *BusinessHandler) ListDatasets(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("qtdata/datasets")
	if err != nil {
		slog.Error("list datasets", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list datasets", http.StatusInternalServerError)
		return
	}
	var items []model.QtDataDataset
	if err := json.Unmarshal(data, &items); err != nil {
		slog.Error("parse datasets", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse datasets", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, items, http.StatusOK)
}

func (h *BusinessHandler) CreateDataset(w http.ResponseWriter, r *http.Request) {
	var item model.QtDataDataset
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode dataset", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtdata/datasets", data)
	if err != nil {
		slog.Error("create dataset", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create dataset", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode dataset with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtdata/datasets", id, data); err != nil {
		slog.Error("persist dataset id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *BusinessHandler) GetDataset(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("qtdata/datasets", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "dataset not found", http.StatusNotFound)
		return
	}
	var item model.QtDataDataset
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse dataset", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse dataset", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) UpdateDataset(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var item model.QtDataDataset
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.ID = id

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode dataset", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtdata/datasets", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "dataset not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) DeleteDataset(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("qtdata/datasets", id); err != nil {
		WriteError(w, "NOT_FOUND", "dataset not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// --- QtRecurit Resumes ---

func (h *BusinessHandler) ImportResume(w http.ResponseWriter, r *http.Request) {
	var item model.QtRecuritResume
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.CandidateName == "" {
		WriteError(w, "VALIDATION_ERROR", "candidate_name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode resume", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtrecurit/resumes", data)
	if err != nil {
		slog.Error("create resume", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create resume", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode resume with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtrecurit/resumes", id, data); err != nil {
		slog.Error("persist resume id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *BusinessHandler) UpdateResumeStage(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	data, err := h.store.Get("qtrecurit/resumes", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "resume not found", http.StatusNotFound)
		return
	}
	var item model.QtRecuritResume
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse resume", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse resume", http.StatusInternalServerError)
		return
	}

	var body struct {
		Stage string `json:"stage"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.Stage = body.Stage

	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode resume", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtrecurit/resumes", id, data); err != nil {
		WriteError(w, "INTERNAL_ERROR", "failed to update resume", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}

func (h *BusinessHandler) CreateInterview(w http.ResponseWriter, r *http.Request) {
	var item model.QtRecuritInterview
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if item.Candidate == "" {
		WriteError(w, "VALIDATION_ERROR", "candidate is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(item)
	if err != nil {
		slog.Error("encode interview", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("qtrecurit/interviews", data)
	if err != nil {
		slog.Error("create interview", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create interview", http.StatusInternalServerError)
		return
	}

	item.ID = id
	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode interview with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtrecurit/interviews", id, data); err != nil {
		slog.Error("persist interview id", "error", err)
	}

	WriteJSON(w, item, http.StatusCreated)
}

func (h *BusinessHandler) UpdateInterviewFeedback(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	data, err := h.store.Get("qtrecurit/interviews", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "interview not found", http.StatusNotFound)
		return
	}
	var item model.QtRecuritInterview
	if err := json.Unmarshal(data, &item); err != nil {
		slog.Error("parse interview", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse interview", http.StatusInternalServerError)
		return
	}

	var body struct {
		Feedback string `json:"feedback"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	item.Feedback = body.Feedback

	data, err = json.Marshal(item)
	if err != nil {
		slog.Error("encode interview", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("qtrecurit/interviews", id, data); err != nil {
		WriteError(w, "INTERNAL_ERROR", "failed to update interview", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, item, http.StatusOK)
}
