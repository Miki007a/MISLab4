import 'package:flutter/material.dart';
import '../models/exam.dart';

class AddExamScreen extends StatefulWidget {
  @override
  _AddExamPageState createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Додај полагање')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Предмет'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Локација'),
            ),
            ListTile(
              title: Text("Избери датум"),
              subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate)
                  setState(() {
                    _selectedDate = picked;
                  });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Додај полагање во базата на податоци
                final examm = exam(
                  date: _selectedDate,
                  location: _locationController.text,
                  subject: _subjectController.text,
                );

                // Додадете го полагањето во календарот или база на податоци
                Navigator.pop(context, examm);
              },
              child: Text('Додај'),
            ),
          ],
        ),
      ),
    );
  }
}
