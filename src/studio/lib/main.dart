/// APP入口

import 'package:flutter/material.dart';


/// APP入口函数
void main() {
  runApp(const QtAdminStudio());
}

/// APP类
class QtAdminStudio extends StatelessWidget {
  const QtAdminStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮管理后台',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        /// 项目列表页面
        '/':  (context) => const Text('首页'),
        
      }
    );
  }
}
