# 薪资计算器

## 领域模型

用户 User：
- id: 

职级 Rank:
- id:  
- level: 3
- series: T
- salary_rate: 40

用户职级关联：
- id: 
- user_id:
- rank_id:

日报 Diary:
- id:
- user_id: 用户 ID 
- date: 2025-06-01
- durarion: 1.5
- description: 具体做了什么

薪资 Salary:
- id:
- month
- salary 


## 领域服务

薪资计算服务 SalaryCalculator:

