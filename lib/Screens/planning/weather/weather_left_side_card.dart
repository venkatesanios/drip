
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Widget weatherCardLeft({
  required String city,
   required String date,
   required String time,
  required String temperature,
  required String feelsLike,
  required IconData weatherIcon,
  required String wind,
  required String humidity,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.location_solid),
              const SizedBox(width: 6),
              Text(city),
            ],
          ),
          const SizedBox(height: 12),

          Text(date),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temperature,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text("Feel Like $feelsLike °C"),
                ],
              ),
              const SizedBox(width: 30),
              TimeOfDayIcon(time: time),
              // Icon(weatherIcon, size: 100, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  CupertinoIcons.wind,
                  "Wind Status",
                  wind,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  CupertinoIcons.drop_fill,
                  "Humidity",
                  humidity,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget sunCard() {
  return const Row(
    children: [
      Expanded(child: _SunTimeCard("Sunrise", "6:10 AM",'assets/Images/sunrise.png')),
      SizedBox(width: 12),
      Expanded(child: _SunTimeCard("Sunset", "6:45 PM",'assets/Images/sunset.png')),

    ],
  );
}

class _SunTimeCard extends StatelessWidget {
  final String title;
  final String time;
  final String image;

  const _SunTimeCard(this.title, this.time,this.image);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2F8F7A),
        borderRadius: BorderRadius.circular(14),
      ),
      child:
      Row(
        children: [
          Image.asset(image,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 5,),
          Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),

    );
  }
}


class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox( this.icon,this.title, this.value,);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              Text(title),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


class TimeOfDayIcon extends StatelessWidget {
  final String time;

  const TimeOfDayIcon({
    super.key,
    required this.time,
  });

  int get hour => int.parse(time.split(':')[0]);

  @override
  Widget build(BuildContext context) {
    if (hour >= 5 && hour < 12) {
      return const TimeIcon(
        icon: Icons.wb_twilight,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFF9C4),
            Color(0xFFFFC107),
            Color(0xFFFF8F00),
          ],
        ),
        glowColor: Colors.orange,
      );
    } else if (hour >= 12 && hour < 17) {
      return const TimeIcon(
        icon: Icons.wb_sunny,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFFDE7),
            Color(0xFFFFEB3B),
            Color(0xFFFFC107),
          ],
        ),
        glowColor: Colors.yellow,
      );
    } else if (hour >= 17 && hour < 19) {
      return const TimeIcon(
        icon: Icons.wb_twilight,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFE0B2),
            Color(0xFFFF8A65),
            Color(0xFFD84315),
          ],
        ),
        glowColor: Colors.deepOrange,
      );
    } else {
      return const TimeIcon(
        icon: Icons.nights_stay,
        gradient: RadialGradient(
          colors: [
            Color(0xFFB39DDB),
            Color(0xFF5E35B1),
            Color(0xFF311B92),
          ],
        ),
        glowColor: Colors.deepPurple,
      );
    }
  }
}
/// 🌗 REUSABLE TIME ICON
class TimeIcon extends StatelessWidget {
  final IconData icon;
  final RadialGradient gradient;
  final Color glowColor;

  const TimeIcon({
    super.key,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        ),

      ],
    );
  }
}