import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/church.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportPopup extends StatefulWidget {
  const ReportPopup({super.key, required this.church});

  final Church church;

  @override
  State<ReportPopup> createState() => _ReportPopupState();
}

class _ReportPopupState extends State<ReportPopup> {

  int? _selectedProblemType = 0;
  final _problemLabels = [
    "Rossz pozíció",
    "Rossz miseidőpont",
    "Egyéb"
  ];

  var _descriptionController = TextEditingController();
  var _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Hibajelentés",
            style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 30),
        DropdownButton(
            value: _selectedProblemType,
            style: Theme.of(context).textTheme.bodyLarge,
            items: List.generate(3, (index) => DropdownMenuItem<int>(value: index, child: Text(_problemLabels[index]))),
              onChanged: (int? value) {
                // This is called when the user selects an item.
                setState(() {
                  _selectedProblemType = value!;
                });
              },
        ),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(labelText: 'Hiba leírása', enabledBorder: UnderlineInputBorder()),
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email cím (opcionális)', enabledBorder: UnderlineInputBorder()),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {Navigator.pop(context);},
                child: const Text('Mégse')
            ),
            TextButton(
                onPressed: _sendReport,
                child: const Text('Küldés')
            ),
          ],
        )
      ],
    );
  }

  void _sendReport() async {

    final response = await http.post(
      Uri.parse('https://miserend.hu/api/v4/report'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>
        {
          'tid': widget.church.id.toString(),
          'pid': _selectedProblemType!.toString(),
          'text': _descriptionController.text,
          'email': _emailController.text,
          'dbdate': '2025-04-18'
        }
      ),
    );

    if (context.mounted) {
      if (response.statusCode == HttpStatus.ok) {
        const snackBar = SnackBar(content: Text('Hibajelentés elküldve'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      }
      else {
        const snackBar = SnackBar(content: Text('Hibajelentés sikertelen!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
