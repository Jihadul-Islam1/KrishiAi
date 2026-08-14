import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7F5,
      ), // অ্যাপের নিচের অংশের লাইট ব্যাকগ্রাউন্ড
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. টপ হেডার সেকশন (ব্যাকগ্রাউন্ড ইমেজ এবং ওয়েদার কার্ড)
            Stack(
              clipBehavior: Clip.none,
              children: [
                // মেইন ব্যাকগ্রাউন্ড ইমেজ (আগের agro.png ইমেজটিই এখানে ব্যাকগ্রাউন্ড হিসেবে থাকবে)
                Container(
                  height: screenSize.height * 0.42,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/agro.png',
                      ), // আপনার প্রজেক্ট পাথ
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                // ইমেজের ওপর হালকা ডার্ক ইফেক্ট যাতে টপ টেক্সটগুলো সুন্দর ও স্পষ্ট দেখায়
                Container(
                  height: screenSize.height * 0.42,
                  color: Colors.black.withValues(alpha: 0.25),
                ),

                // হেডার টেক্সট এবং ইউজার প্রোফাইল এরিয়া
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // প্রোফাইল রো (নাম, তারিখ এবং গোল প্রোফাইল পিকচার)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello Jonathan.S',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Monday, 02 Sep 2025',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            // ইউজার প্রোফাইল পিকচার (সার্কেল এভাটার)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // মেইন স্লোগান টেক্সট
                        const Text(
                          'Farming Made Simple,\nSmarter, and Sustainable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // সার্চ বার এবং লোকেশন বাটন
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 15),
                                    Icon(Icons.search, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      'Search places',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ২. ওয়েদার ওভারল্যাপ কার্ড (গ্লাস মরফিজম শেড)
                Positioned(
                  top: screenSize.height * 0.32,
                  left: 20,
                  right: 20,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.push('/weather'),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2E3B2E,
                          ).withValues(alpha: 0.85), // স্ক্রিনশটের ডার্ক শেড কালার
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // সাপ্তাহিক দিনগুলোর হরিজন্টাল লিস্ট
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildWeatherDay(
                                  '09',
                                  Icons.cloudy_snowing,
                                  '28°',
                                  false,
                                ),
                                _buildWeatherDay(
                                  '10',
                                  Icons.wb_cloudy_outlined,
                                  '30°',
                                  false,
                                ),
                                _buildWeatherDay(
                                  '11',
                                  Icons.wb_sunny,
                                  '32°',
                                  true,
                                ), // আজকের দিনটি হাইলাইটেড অরেঞ্জ কালার
                                _buildWeatherDay(
                                  '12',
                                  Icons.wb_sunny_outlined,
                                  '36°',
                                  false,
                                ),
                                _buildWeatherDay(
                                  '13',
                                  Icons.cloud_queue,
                                  '35°',
                                  false,
                                ),
                                _buildWeatherDay(
                                  '14',
                                  Icons.wb_sunny_outlined,
                                  '34°',
                                  false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Monday, 02 Sep 2025',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '32°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.wb_sunny,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Bright and Sunny',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.wb_cloudy,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Weather',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Stable for plant growth',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ওয়েদার কার্ডের নিচের স্পেসিং অ্যাডজাস্টমেন্ট
            SizedBox(height: screenSize.height * 0.16),

            // ৩. ক্রপ ফিল্টার ক্যাটাগরি চিপস (Wheat, Grapes, Potato)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCropChip(
                      'Wheat',
                      const Color(0xFFFF9800),
                      true,
                      onTap: () => context.push('/farm/crops'),
                    ), // Wheat সিলেক্টেড (অরেঞ্জ কালার)
                    const SizedBox(width: 10),
                    _buildCropChip(
                      'Grapes',
                      Colors.white,
                      false,
                      onTap: () => context.push('/farm/crops'),
                    ),
                    const SizedBox(width: 10),
                    _buildCropChip(
                      'Potato',
                      Colors.white,
                      false,
                      onTap: () => context.push('/farm/crops'),
                    ),
                    const SizedBox(width: 10),
                    _buildCropChip(
                      'Rice',
                      Colors.white,
                      false,
                      onTap: () => context.push('/farm/crops'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ৪. "My Fields" টাইটেল রো
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Fields',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'See all >',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ৫. ফিল্ড প্রভিউ কার্ড (Emerald Valley Plot F5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // কন্টেইনার ব্যাকগ্রাউন্ড গ্রিন শেড (এখানে আপনার ফিল্ডের কাস্টম ইমেজ বসাতে পারেন)
                      Container(
                        color: const Color(0xFF1B4D22),
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          child: Icon(
                            Icons.gite_outlined,
                            color: Colors.white24,
                            size: 80,
                          ),
                        ),
                      ),

                      // ছবির ওপরে স্মুথ ডার্ক লিনিয়ার গ্রেডিয়েন্ট
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),

                      // কার্ডের ভেতরের টেক্সট এবং রেটিং বাটন এলিমেন্ট
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // রেটিং এবং লাভ/হার্ট বাটন রো
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),

                            // বটম এরিয়া: লোকেশন কো-অর্ডিনেট এবং টাইটেল
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '40.7128 N | 74.0060 W',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 
                                              0.6,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Emerald Valley Plot F5',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // গোল সাদা রঙের এক্সটার্নাল নেভিগেশন বাটন (↗)
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_outward,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // সপ্তাহের দিনগুলোর কাস্টম মেথড উইজেট
  Widget _buildWeatherDay(
    String day,
    IconData icon,
    String temp,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFF9800)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Icon(icon, color: isSelected ? Colors.white : Colors.amber, size: 18),
          const SizedBox(height: 6),
          Text(
            temp,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ক্যাটাগরি চিপস কাস্টম মেথড উইজেট
  Widget _buildCropChip(
    String label,
    Color bgColor,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: isSelected
                ? Colors.white24
                : Colors.green.withValues(alpha: 0.2),
            child: Icon(
              Icons.eco,
              size: 12,
              color: isSelected ? Colors.white : Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: chip,
      ),
    );
  }
}
// Alias used by lib/main.dart - the original agro.png dashboard.
typedef HomeScreen = HomeDashboard;
