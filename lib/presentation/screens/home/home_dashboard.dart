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
                                  'আসসালামু, রহিম ভাই',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'সোমবার, ০২ সেপ্টেম্বর ২০২৫',
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
                          'চাষ হোক সহজ,\nস্মার্ট এবং টেকসই',
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
                                      'স্থান খুঁজুন',
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
                          color: const Color(0xFF2E3B2E).withValues(
                            alpha: 0.85,
                          ), // স্ক্রিনশটের ডার্ক শেড কালার
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
                              'সোমবার, ০২ সেপ্টেম্বর ২০২৫',
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
                                      'উজ্জ্বল রোদ',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'আবহাওয়া',
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
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
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
                                        'ফসলের জন্য উপযুক্ত',
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

            // ৩. ক্রপ ফিল্টার ক্যাটাগরি চিপস (গম, আঙুর, আলু, ধান)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCropChip(
                      'গম',
                      const Color(0xFFFF9800),
                      true,
                      onTap: () => context.push('/farm/crops'),
                    ), // গম সিলেক্টেড (অরেঞ্জ কালার)
                    const SizedBox(width: 10),
                    _buildCropChip(
                      'আঙুর',
                      Colors.white,
                      false,
                      onTap: () => context.push('/farm/crops'),
                    ),
                    const SizedBox(width: 10),
                    _buildCropChip(
                      'আলু',
                      Colors.white,
                      false,
                      onTap: () => context.push('/farm/crops'),
                    ),
                    const SizedBox(width: 10),
                    _buildCropChip(
                      'ধান',
                      Colors.white,
                      false,
                      onTap: () => context.push('/farm/crops'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ৪. "আমার জমি" টাইটেল রো
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'আমার জমি',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'সব দেখুন >',
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
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'খুলনা, বাংলাদেশ',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'জমি: প্লট এফ-৫',
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
            // ৬. "দ্রুত টুলস" — কোডে থাকা বাকি স্ক্রিনগুলোতে যাওয়ার শর্টকাট গ্রিড
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'দ্রুত টুলস',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _buildToolCard(
                          title: 'AI ক্রপ ডাক্তার',
                          subtitle: 'রোগ শনাক্ত',
                          icon: Icons.camera_alt,
                          onTap: () => context.push('/ai/scan'),
                        ),
                        _buildToolCard(
                          title: 'AI সহকারী',
                          subtitle: 'প্রশ্ন করুন',
                          icon: Icons.smart_toy,
                          onTap: () => context.go('/ai'),
                        ),
                        _buildToolCard(
                          title: 'আবহাওয়া',
                          subtitle: '৭ দিনের পূর্বাভাস',
                          icon: Icons.wb_sunny,
                          onTap: () => context.push('/weather'),
                        ),
                        _buildToolCard(
                          title: 'বাজার দর',
                          subtitle: 'আজকের দাম',
                          icon: Icons.storefront,
                          onTap: () => context.go('/market'),
                        ),
                        _buildToolCard(
                          title: 'রোগ লাইব্রেরি',
                          subtitle: 'চিকিৎসা গাইড',
                          icon: Icons.local_library,
                          onTap: () => context.push('/library'),
                        ),
                        _buildToolCard(
                          title: 'খরচ ট্র্যাকার',
                          subtitle: 'খাতা-কাটা হিসাব',
                          icon: Icons.account_balance_wallet,
                          onTap: () => context.push('/expenses'),
                        ),
                        _buildToolCard(
                          title: 'লাভ গণনা',
                          subtitle: 'ফসলের মুনাফা',
                          icon: Icons.calculate,
                          onTap: () => context.push('/profit'),
                        ),
                        _buildToolCard(
                          title: 'বিশ্লেষণ',
                          subtitle: 'চার্ট ও রিপোর্ট',
                          icon: Icons.bar_chart,
                          onTap: () => context.push('/analytics'),
                        ),
                        _buildToolCard(
                          title: 'সেচ পরামর্শ',
                          subtitle: 'কখন, কতটুকু',
                          icon: Icons.water_drop,
                          onTap: () => context.push('/irrigation'),
                        ),
                        _buildToolCard(
                          title: 'সার পরামর্শ',
                          subtitle: 'ডোজ নির্দেশনা',
                          icon: Icons.grass,
                          onTap: () => context.push('/fertilizer'),
                        ),
                        _buildToolCard(
                          title: 'স্ক্যান ইতিহাস',
                          subtitle: 'আগের রিপোর্ট',
                          icon: Icons.history,
                          onTap: () => context.push('/ai/history'),
                        ),
                        _buildToolCard(
                          title: 'নোটিফিকেশন',
                          subtitle: 'আপডেট ও অ্যালার্ট',
                          icon: Icons.notifications,
                          onTap: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                  ],
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
          color: isSelected
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.2),
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

  // দ্রুত টুলস কার্ড — গ্রিনিশ গ্রেডিয়েন্ট + উজ্জ্বল আইকন ব্যাজ
  Widget _buildToolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF1F8F2)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B4D22).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B4D22),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4F6B52),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFF2E7D32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alias used by lib/main.dart - the original agro.png dashboard.
typedef HomeScreen = HomeDashboard;
