package api

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/quanttide/qtadmin-provider/internal/model"
	"github.com/quanttide/qtadmin-provider/internal/store"
)

type HumanHandler struct {
	store store.Store
}

func NewHumanHandler(st store.Store) *HumanHandler {
	return &HumanHandler{store: st}
}

// --- Employees ---

func (h *HumanHandler) ListEmployees(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("human/employees")
	if err != nil {
		slog.Error("list employees", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list employees", http.StatusInternalServerError)
		return
	}
	var employees []model.Employee
	if err := json.Unmarshal(data, &employees); err != nil {
		slog.Error("parse employees", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse employees", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, employees, http.StatusOK)
}

func (h *HumanHandler) CreateEmployee(w http.ResponseWriter, r *http.Request) {
	var emp model.Employee
	if err := json.NewDecoder(r.Body).Decode(&emp); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if emp.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(emp)
	if err != nil {
		slog.Error("encode employee", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("human/employees", data)
	if err != nil {
		slog.Error("create employee", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create employee", http.StatusInternalServerError)
		return
	}

	emp.ID = id
	data, err = json.Marshal(emp)
	if err != nil {
		slog.Error("encode employee with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/employees", id, data); err != nil {
		slog.Error("persist employee id", "error", err)
	}

	WriteJSON(w, emp, http.StatusCreated)
}

func (h *HumanHandler) GetEmployee(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("human/employees", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "employee not found", http.StatusNotFound)
		return
	}
	var emp model.Employee
	if err := json.Unmarshal(data, &emp); err != nil {
		slog.Error("parse employee", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse employee", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, emp, http.StatusOK)
}

func (h *HumanHandler) UpdateEmployee(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var emp model.Employee
	if err := json.NewDecoder(r.Body).Decode(&emp); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	emp.ID = id

	data, err := json.Marshal(emp)
	if err != nil {
		slog.Error("encode employee", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/employees", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "employee not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, emp, http.StatusOK)
}

func (h *HumanHandler) DeleteEmployee(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("human/employees", id); err != nil {
		WriteError(w, "NOT_FOUND", "employee not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// --- Departments ---

func (h *HumanHandler) ListDepartments(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("human/departments")
	if err != nil {
		slog.Error("list departments", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list departments", http.StatusInternalServerError)
		return
	}
	var departments []model.Department
	if err := json.Unmarshal(data, &departments); err != nil {
		slog.Error("parse departments", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse departments", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, departments, http.StatusOK)
}

func (h *HumanHandler) CreateDepartment(w http.ResponseWriter, r *http.Request) {
	var dept model.Department
	if err := json.NewDecoder(r.Body).Decode(&dept); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if dept.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(dept)
	if err != nil {
		slog.Error("encode department", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("human/departments", data)
	if err != nil {
		slog.Error("create department", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create department", http.StatusInternalServerError)
		return
	}

	dept.ID = id
	data, err = json.Marshal(dept)
	if err != nil {
		slog.Error("encode department with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/departments", id, data); err != nil {
		slog.Error("persist department id", "error", err)
	}

	WriteJSON(w, dept, http.StatusCreated)
}

func (h *HumanHandler) GetDepartment(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("human/departments", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "department not found", http.StatusNotFound)
		return
	}
	var dept model.Department
	if err := json.Unmarshal(data, &dept); err != nil {
		slog.Error("parse department", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse department", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, dept, http.StatusOK)
}

func (h *HumanHandler) UpdateDepartment(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var dept model.Department
	if err := json.NewDecoder(r.Body).Decode(&dept); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	dept.ID = id

	data, err := json.Marshal(dept)
	if err != nil {
		slog.Error("encode department", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/departments", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "department not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, dept, http.StatusOK)
}

func (h *HumanHandler) DeleteDepartment(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("human/departments", id); err != nil {
		WriteError(w, "NOT_FOUND", "department not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// --- Positions ---

func (h *HumanHandler) ListPositions(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("human/positions")
	if err != nil {
		slog.Error("list positions", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list positions", http.StatusInternalServerError)
		return
	}
	var positions []model.Position
	if err := json.Unmarshal(data, &positions); err != nil {
		slog.Error("parse positions", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse positions", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, positions, http.StatusOK)
}

func (h *HumanHandler) CreatePosition(w http.ResponseWriter, r *http.Request) {
	var pos model.Position
	if err := json.NewDecoder(r.Body).Decode(&pos); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if pos.Name == "" {
		WriteError(w, "VALIDATION_ERROR", "name is required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(pos)
	if err != nil {
		slog.Error("encode position", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("human/positions", data)
	if err != nil {
		slog.Error("create position", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create position", http.StatusInternalServerError)
		return
	}

	pos.ID = id
	data, err = json.Marshal(pos)
	if err != nil {
		slog.Error("encode position with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/positions", id, data); err != nil {
		slog.Error("persist position id", "error", err)
	}

	WriteJSON(w, pos, http.StatusCreated)
}

func (h *HumanHandler) GetPosition(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("human/positions", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "position not found", http.StatusNotFound)
		return
	}
	var pos model.Position
	if err := json.Unmarshal(data, &pos); err != nil {
		slog.Error("parse position", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse position", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, pos, http.StatusOK)
}

func (h *HumanHandler) UpdatePosition(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var pos model.Position
	if err := json.NewDecoder(r.Body).Decode(&pos); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	pos.ID = id

	data, err := json.Marshal(pos)
	if err != nil {
		slog.Error("encode position", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/positions", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "position not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, pos, http.StatusOK)
}

func (h *HumanHandler) DeletePosition(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("human/positions", id); err != nil {
		WriteError(w, "NOT_FOUND", "position not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// --- Classification Rules ---

func (h *HumanHandler) ListRules(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("human/rules")
	if err != nil {
		slog.Error("list rules", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list rules", http.StatusInternalServerError)
		return
	}
	var rules []model.PositionRule
	if err := json.Unmarshal(data, &rules); err != nil {
		slog.Error("parse rules", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse rules", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, rules, http.StatusOK)
}

func (h *HumanHandler) CreateRule(w http.ResponseWriter, r *http.Request) {
	var rule model.PositionRule
	if err := json.NewDecoder(r.Body).Decode(&rule); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if rule.Name == "" || len(rule.Keywords) == 0 {
		WriteError(w, "VALIDATION_ERROR", "name and keywords are required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(rule)
	if err != nil {
		slog.Error("encode rule", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("human/rules", data)
	if err != nil {
		slog.Error("create rule", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create rule", http.StatusInternalServerError)
		return
	}

	rule.ID = id
	data, err = json.Marshal(rule)
	if err != nil {
		slog.Error("encode rule with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/rules", id, data); err != nil {
		slog.Error("persist rule id", "error", err)
	}

	WriteJSON(w, rule, http.StatusCreated)
}

func (h *HumanHandler) UpdateRule(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var rule model.PositionRule
	if err := json.NewDecoder(r.Body).Decode(&rule); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	rule.ID = id

	data, err := json.Marshal(rule)
	if err != nil {
		slog.Error("encode rule", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("human/rules", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "rule not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, rule, http.StatusOK)
}

func (h *HumanHandler) DeleteRule(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("human/rules", id); err != nil {
		WriteError(w, "NOT_FOUND", "rule not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
