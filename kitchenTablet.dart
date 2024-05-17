import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:personal_bla_eda/settings/settings_interface.dart';
import 'package:personal_bla_eda/settings/settings_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/kitchenApi/loadKitchenOrders.dart';

class TabletKitchenOrdersWidget extends StatefulWidget {
  const TabletKitchenOrdersWidget({Key? key}) : super(key: key);

  @override
  _TabletKitchenOrdersWidgetState createState() => _TabletKitchenOrdersWidgetState();
}

class _TabletKitchenOrdersWidgetState extends State<TabletKitchenOrdersWidget> with AutomaticKeepAliveClientMixin {
  late SharedPreferences prefs;
  late LoadKitchenOrders loadKitchenOrders;
  late Timer _timer;
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Отменяем таймер при уничтожении виджета
    super.dispose();
  }

  Future<void> _initDependencies() async {
    prefs = await SharedPreferences.getInstance();
    final settings_interface sett = settings_repo(preferences: prefs);
    loadKitchenOrders = LoadKitchenOrders(prefs: prefs, sett: sett);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final List<Map<String, dynamic>> data = await loadKitchenOrders.loadOrders();
      // Обновляем состояние только при изменении данных
      if (!listEquals(_orders, data)) {
        setState(() {
          _orders = data;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказы'),
      ),
      body: _loading
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns in grid
              childAspectRatio: 0.7, // Aspect ratio for each grid item
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
                final order = _orders[index];
                final orderDescription = order['description'];
                final List<dynamic> lines = orderDescription['Lines'];
                final Map<String, dynamic> oDescription = orderDescription['Description'];
                final List<dynamic> cookers = oDescription['Cook'];
                return Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    children: [
                      InkWell(
                        child: Container(
                          width: 450,
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade200,
                                Colors.grey.shade200,
                                Colors.grey
                              ],
                              stops: [0.0, 0.99, 0.99, 1.0],
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Text(
                                  order['order'].toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Table(
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Text(
                                          'Сумма: ',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TableCell(
                                        child: Text(
                                          order['summ'].toString() + ' ₽',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Text(
                                          'Время: ',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TableCell(
                                        child: Text(
                                          order['time'].toString() + '⌚',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Text(
                                          '',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      Text(''),
                                    ],
                                  )
                                ],
                              ),
                              Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      child: Text(
                                        'ФИО повара:\n',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Text(
                                          'Цех:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  for (var cook in cookers)
                                    TableRow(children: [
                                    TableCell(
                                      child: Text(
                                        cook['usr']+"\n",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Text(
                                          cook['department'] == "cold" ? "🧊" : cook['department'] == "hot" ? "🔥" : "🧊🔥",
                                          style: TextStyle(
                                              color: cook['department'] == "cold" ? Colors.blue  : cook['department'] == "hot" ? Colors.red  : Colors.green,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ]
                              ),
                              Table(
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(child: InkWell(
                                        onTap: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  child: Wrap(
                                                    children: <Widget>[
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Горячий цех',
                                                        icon: Icons.local_fire_department,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Взять горячий цех',
                                                            'Пиццы...',
                                                            () {
                                                              loadKitchenOrders.editPers(order['id'].toString(), prefs.getInt('id').toString(), 'hot');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Холодный цех',
                                                        icon: Icons.severe_cold_outlined,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Взять холодный цех',
                                                            'Роллы...',
                                                            () {
                                                              loadKitchenOrders.editPers(order['id'].toString(), prefs.getInt('id').toString(), 'cold');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Взять оба цеха',
                                                        icon: Icons.error_outline,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Взять оба цеха',
                                                            'Только если 1 сотрудник в смене!',
                                                            () {
                                                              loadKitchenOrders.editPers(order['id'].toString(), prefs.getInt('id').toString(), 'cold_hot');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                            padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(7),
                                              color: Colors.blueGrey,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black,
                                                  spreadRadius: 0,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Взять цех',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            
                                          ),
                                      )),
                                      TableCell(child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  child: Wrap(
                                                    children: <Widget>[
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Отказаться от исполнения',
                                                        icon: Icons.close_rounded,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Внимение!!!',
                                                            'Убедитесь, что этот заказ приготовит другой повар!',
                                                            () {
                                                              loadKitchenOrders.editPers(order['id'].toString(), prefs.getInt('id').toString(), 'rem');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ]
                                                  )
                                                );
                                              },
                                          );
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                            padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(7),
                                              color: Colors.blueGrey,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black,
                                                  spreadRadius: 0,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              'Сняться',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                      )),
                                    ]
                                  )
                                ],
                              ),
                              Text(
                                '\n---------------------------------------------',
                                style: TextStyle(color: Colors.black),
                              ),
                              Table(
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      child: Text(
                                        'Название:',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Text(
                                          'Кол-во:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: Text(
                                          'Цех:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  for (var line in lines)
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Text(
                                            line['Description'],
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        TableCell(
                                          child: Center(
                                            child: Text(
                                              (line['Qty'] / 1000)
                                                  .toString()
                                                  .substring(
                                                      0,
                                                      (line['Qty'] / 1000)
                                                          .toString()
                                                          .length -
                                                          2),
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Center(
                                            child: Text(
                                              '-',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              Text(
                                '---------------------------------------------\n',
                                style: TextStyle(color: Colors.black),
                              ),
                              Table(
                                children: [
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  child: Wrap(
                                                    children: <Widget>[
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Начать готовить',
                                                        icon: Icons.soup_kitchen,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Начать готовить',
                                                            'Начать готовить этот заказ?',
                                                            () {
                                                              loadKitchenOrders.setOrderStatus(order['id'].toString(), '1');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Готов',
                                                        icon: Icons.check_circle_outline,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Подтверждение',
                                                            'Заказ точно готов к сборке?',
                                                            () {
                                                              loadKitchenOrders.setOrderStatus(order['id'].toString(), '2');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      buildOrderStatusButton(
                                                        order: order,
                                                        status: 'Собран(вызов курьера)',
                                                        icon: Icons.delivery_dining,
                                                        onTap: () async {
                                                          await confirmActionDialog(
                                                            context,
                                                            'Подтверждение',
                                                            'Провертьте заказ Внимательно!',
                                                            () {
                                                              loadKitchenOrders.setOrderStatus(order['id'].toString(), '3');
                                                              Navigator.pop(context); // Закрываем модальное окно
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                            padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(7),
                                              color: getStatusColor(order['statusid'].toString()),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black,
                                                  spreadRadius: 0,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              order['status'].toString(),
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget buildOrderStatusButton({
    required Map<String, dynamic> order,
    required String status,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(status),
      onTap: onTap,
    );
  }

  Future<void> confirmActionDialog(BuildContext context, String title, String content, VoidCallback onConfirmed) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Да'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  Color getStatusColor(String statusId) {
    switch (statusId) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.black;
      default:
        return Colors.red;
    }
  }
}
