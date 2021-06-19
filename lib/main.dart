import 'dart:io';

import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:expenses/models/transaction.dart';
import 'components/transaction_form.dart';
import 'components/transaction_list.dart';


main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
            button: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13
            )
          ),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            )
          )
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage()
    );
  }
}


class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  final List<Transaction> _transactions = [];
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  List<Transaction> get _recentTransactions{
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
          Duration(days: 7)
      ));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date){
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id){
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (_){
          return TransactionForm(_addTransaction);
        }
    );
  }

  Widget _getIconButton(IconData icon, Function fn){
    return Platform.isIOS ?
        GestureDetector(onTap: fn, child: Icon(icon))
      : IconButton(onPressed: fn, icon: Icon(icon));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final iconList = Platform.isIOS ? CupertinoIcons.refresh : Icons.list;
    final chartList = Platform.isIOS ? CupertinoIcons.refresh : Icons.bar_chart;

    final actions = [
      if(isLandscape)
        _getIconButton(
            _showChart ? iconList : chartList,
            (){
              setState(() {
                _showChart = !_showChart;
              });
            }
        ),
      _getIconButton(
          Platform.isIOS ? CupertinoIcons.add : Icons.add,
          () => _openTransactionFormModal(context),
      ),
    ];

    final PreferredSizeWidget appBar = Platform.isIOS ?
      CupertinoNavigationBar(
        middle: Text('Despesas Pessoais'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      )
    : AppBar(
          title: Text('Despesas Pessoais'),
          actions: actions
    );
    final availebleHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    final bodyPage = SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // if(isLandscape)
              //   Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text('Exibir Gráfico'),
              //       Switch.adaptive(value: _showChart, onChanged: (value){
              //         setState(() {
              //           _showChart = value;
              //         });
              //       },
              //       activeColor: Theme.of(context).accentColor,
              //       )
              //     ],
              //   ),
              if(_showChart || !isLandscape)
                Container(
                    height: availebleHeight *  (isLandscape ? 0.8 : 0.30),
                    child: Chart(_recentTransactions)
                ),
              if(!_showChart || !isLandscape)
                Container(
                    height: availebleHeight *  (isLandscape ? 1 : 0.7),
                    child: TransactionList(_transactions, _removeTransaction)
                ),
            ],
          ),
        )
    );


    return Platform.isIOS ?
      CupertinoPageScaffold(
          navigationBar: appBar,
          child: bodyPage
      )
    : Scaffold(
      appBar: appBar,
      body: bodyPage,
      floatingActionButton: Platform.isIOS ?
         Column()
       : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
