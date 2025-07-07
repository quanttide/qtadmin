from .employee import Employee, EmployeeCreate, EmployeeRead, EmployeeWithSalaries
from .salary import SalaryCalculation, SalaryCalculationCreate, SalaryCalculationRead, SalaryCalculationBase

# 显式重建包含嵌套关系的模型
EmployeeWithSalaries.model_rebuild()

# 确保所有表模型都被注册
__all__ = [
    "Employee", "EmployeeCreate", "EmployeeRead", "EmployeeWithSalaries",
    "SalaryCalculation", "SalaryCalculationCreate", "SalaryCalculationRead", "SalaryCalculationBase"
]