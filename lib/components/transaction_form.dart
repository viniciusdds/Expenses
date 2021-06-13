import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {

  final void Function(String, double, DateTime) onSubmit;

  TransactionForm(this.onSubmit);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _valueControlller = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  _submitForm(){
    final title = _titleController.text;
    final value = double.tryParse(_valueControlller.text) ?? 0.0;

    if(title.isEmpty || value <= 0 || _selectedDate == null){
      return;
    }

    widget.onSubmit(title, value, _selectedDate);
  }

  _showDatePicker(){
     showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
       if(pickedDate == null){
         return;
       }

       setState(() {
         _selectedDate = pickedDate;
       });
    });
  }

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            right: 10,
            left: 10,
            bottom: 10 + MediaQuery.of(context).viewInsets.bottom
          ),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                onSubmitted: (_) => _submitForm(),
                decoration: InputDecoration(
                  labelText: 'Titulo',
                ),
              ),
              TextField(
                controller: _valueControlller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _submitForm(),
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                ),
              ),
              Container(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                          _selectedDate == null ?
                            'Nenhuma data selecionada!'
                          :
                            'Data Selecionda: ${ DateFormat('dd/MM/y').format(_selectedDate)}',
                          style: TextStyle(
                            fontSize: 13
                          ),
                      ),
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor
                        ),
                        onPressed: _showDatePicker,
                        child: Text(
                            'Selecionar Data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                        )
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                     ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Nova Transação'),
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).textTheme.button.color,
                          backgroundColor: Theme.of(context).primaryColor
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
