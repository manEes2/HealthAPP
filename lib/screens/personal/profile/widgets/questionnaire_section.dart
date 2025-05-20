import 'package:flutter/material.dart';

class QuestionnaireSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final bool editing;
  final VoidCallback onToggleEdit;

  const QuestionnaireSection({
    super.key,
    required this.controllers,
    required this.editing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = controllers.entries.map((entry) {
      final key = entry.key;
      final controller = entry.value;

      IconData icon = Icons.question_answer;
      if (key.toLowerCase().contains("symptom"))
        icon = Icons.sick;
      else if (key.toLowerCase().contains("fat"))
        icon = Icons.scale;
      else if (key.toLowerCase().contains("food"))
        icon = Icons.fastfood;
      else if (key.toLowerCase().contains("history")) icon = Icons.history;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ExpansionTile(
          title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: Icon(icon, color: Colors.brown.shade300),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextFormField(
                controller: controller,
                enabled: editing,
                decoration: InputDecoration(
                  labelText: "Edit $key",
                  filled: true,
                  fillColor: editing ? Colors.white : Colors.brown.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("📝 Questionnaire",
                style: TextStyle(
                    fontFamily: 'Besom',
                    fontSize: 24,
                    color: Colors.brown.shade800)),
            const Spacer(),
            IconButton(
              icon: Icon(editing ? Icons.check_circle : Icons.edit),
              color: editing ? Colors.green : Colors.blueGrey,
              onPressed: onToggleEdit,
            )
          ],
        ),
        ...cards,
      ],
    );
  }
}
