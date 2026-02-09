/// 交易编辑表单页面
/// 
/// 用于创建或编辑交易记录
/// 
/// 该页面包含一个表单，用户可以输入交易的相关信息
/// 包括交易类型、金额、日期等
/// 该页面还提供了保存和取消按钮

import 'package:flutter/material.dart';

class TransactionFormScreen extends StatelessWidget {
  const TransactionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易编辑'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '交易类型'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '金额'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '日期'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 保存逻辑
                },
                child: const Text('保存'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}