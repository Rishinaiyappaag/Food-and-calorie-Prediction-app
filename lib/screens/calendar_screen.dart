import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../routes/global_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalState>(context);

    final mealsForDay = state.meals.where((m) =>
        m["date"].day == selectedDay.day &&
        m["date"].month == selectedDay.month &&
        m["date"].year == selectedDay.year);

    final totalCalories =
        mealsForDay.fold(0.0, (sum, m) => sum + m["calories"]);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Daily Calorie Tracker"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),

          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: Colors.white),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Total: ${totalCalories.toStringAsFixed(0)} kcal",
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),

          Expanded(
            child: ListView(
              children: mealsForDay
                  .map((m) => ListTile(
                        leading: const Icon(Icons.fastfood,
                            color: Colors.purpleAccent),
                        title: Text(m["name"],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text("${m["calories"]} kcal",
                            style: const TextStyle(color: Colors.white70)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
