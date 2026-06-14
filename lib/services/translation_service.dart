class TranslationService {
  static const Map<String, Map<String, String>> _translations = {
    'Hello': {
      'es': 'Hola', 'fr': 'Bonjour', 'de': 'Hallo', 'it': 'Ciao',
      'pt': 'Olá', 'hi': 'नमस्ते', 'ja': 'こんにちは', 'zh': '你好',
      'ar': 'مرحبا', 'ko': '안녕하세요', 'ru': 'Здравствуйте',
      'tr': 'Merhaba', 'nl': 'Hallo', 'sv': 'Hej', 'pl': 'Cześć',
      'vi': 'Xin chào', 'th': 'สวัสดี', 'id': 'Halo',
    },
    'How are you?': {
      'es': '¿Cómo estás?', 'fr': 'Comment allez-vous?', 'de': 'Wie geht es dir?',
      'it': 'Come stai?', 'pt': 'Como vai?', 'hi': 'आप कैसे हैं?',
      'ja': 'お元気ですか？', 'zh': '你好吗？', 'ar': 'كيف حالك؟',
      'ko': '어떻게 지내세요?', 'ru': 'Как дела?', 'tr': 'Nasılsın?',
      'nl': 'Hoe gaat het?', 'sv': 'Hur mår du?', 'pl': 'Jak się masz?',
      'vi': 'Bạn khỏe không?', 'th': 'สบายดีไหม?', 'id': 'Apa kabar?',
    },
    'Good morning': {
      'es': 'Buenos días', 'fr': 'Bonjour', 'de': 'Guten Morgen',
      'it': 'Buongiorno', 'pt': 'Bom dia', 'hi': 'शुभ प्रभात',
      'ja': 'おはようございます', 'zh': '早上好', 'ar': 'صباح الخير',
      'ko': '좋은 아침', 'ru': 'Доброе утро', 'tr': 'Günaydın',
      'nl': 'Goedemorgen', 'sv': 'God morgon', 'pl': 'Dzień dobry',
      'vi': 'Chào buổi sáng', 'th': 'สวัสดีตอนเช้า', 'id': 'Selamat pagi',
    },
    'Good evening': {
      'es': 'Buenas tardes', 'fr': 'Bonsoir', 'de': 'Guten Abend',
      'it': 'Buonasera', 'pt': 'Boa noite', 'hi': 'शुभ संध्या',
      'ja': 'こんばんは', 'zh': '晚上好', 'ar': 'مساء الخير',
      'ko': '좋은 저녁', 'ru': 'Добрый вечер', 'tr': 'İyi akşamlar',
      'nl': 'Goedenavond', 'sv': 'God kväll', 'pl': 'Dobry wieczór',
      'vi': 'Chào buổi tối', 'th': 'สวัสดีตอนเย็น', 'id': 'Selamat malam',
    },
    'Thank you': {
      'es': 'Gracias', 'fr': 'Merci', 'de': 'Danke', 'it': 'Grazie',
      'pt': 'Obrigado', 'hi': 'धन्यवाद', 'ja': 'ありがとう',
      'zh': '谢谢', 'ar': 'شكرا', 'ko': '감사합니다', 'ru': 'Спасибо',
      'tr': 'Teşekkürler', 'nl': 'Dank je', 'sv': 'Tack', 'pl': 'Dziękuję',
      'vi': 'Cảm ơn', 'th': 'ขอบคุณ', 'id': 'Terima kasih',
    },
    'Goodbye': {
      'es': 'Adiós', 'fr': 'Au revoir', 'de': 'Auf Wiedersehen',
      'it': 'Arrivederci', 'pt': 'Tchau', 'hi': 'अलविदा',
      'ja': 'さようなら', 'zh': '再见', 'ar': 'وداعا',
      'ko': '안녕히 계세요', 'ru': 'До свидания', 'tr': 'Hoşça kal',
      'nl': 'Tot ziens', 'sv': 'Hej då', 'pl': 'Do widzenia',
      'vi': 'Tạm biệt', 'th': 'ลาก่อน', 'id': 'Selamat tinggal',
    },
    'See you later': {
      'es': 'Hasta luego', 'fr': 'À plus tard', 'de': 'Bis später',
      'it': 'A dopo', 'pt': 'Até logo', 'hi': 'बाद में मिलते हैं',
      'ja': 'また後で', 'zh': '回头见', 'ar': 'أراك لاحقاً',
      'ko': '나중에 봐요', 'ru': 'Увидимся позже', 'tr': 'Sonra görüşürüz',
      'nl': 'Tot later', 'sv': 'Vi ses senare', 'pl': 'Do zobaczenia później',
      'vi': 'Hẹn gặp lại', 'th': 'แล้วเจอกัน', 'id': 'Sampai jumpa',
    },
    'Yes': {
      'es': 'Sí', 'fr': 'Oui', 'de': 'Ja', 'it': 'Sì', 'pt': 'Sim',
      'hi': 'हाँ', 'ja': 'はい', 'zh': '是', 'ar': 'نعم',
      'ko': '네', 'ru': 'Да', 'tr': 'Evet', 'nl': 'Ja', 'sv': 'Ja',
      'pl': 'Tak', 'vi': 'Có', 'th': 'ใช่', 'id': 'Ya',
    },
    'No': {
      'es': 'No', 'fr': 'Non', 'de': 'Nein', 'it': 'No', 'pt': 'Não',
      'hi': 'नहीं', 'ja': 'いいえ', 'zh': '不是', 'ar': 'لا',
      'ko': '아니요', 'ru': 'Нет', 'tr': 'Hayır', 'nl': 'Nee',
      'sv': 'Nej', 'pl': 'Nie', 'vi': 'Không', 'th': 'ไม่', 'id': 'Tidak',
    },
    'Sorry': {
      'es': 'Lo siento', 'fr': 'Désolé', 'de': 'Entschuldigung',
      'it': 'Mi dispiace', 'pt': 'Desculpe', 'hi': 'माफ़ कीजिए',
      'ja': 'ごめんなさい', 'zh': '对不起', 'ar': 'آسف',
      'ko': '죄송합니다', 'ru': 'Извините', 'tr': 'Üzgünüm',
      'nl': 'Sorry', 'sv': 'Förlåt', 'pl': 'Przepraszam',
      'vi': 'Xin lỗi', 'th': 'ขอโทษ', 'id': 'Maaf',
    },
    'Please': {
      'es': 'Por favor', 'fr': 'S\'il vous plaît', 'de': 'Bitte',
      'it': 'Per favore', 'pt': 'Por favor', 'hi': 'कृपया',
      'ja': 'お願いします', 'zh': '请', 'ar': 'رجاءً',
      'ko': '제발', 'ru': 'Пожалуйста', 'tr': 'Lütfen',
      'nl': 'Alsjeblieft', 'sv': 'Snälla', 'pl': 'Proszę',
      'vi': 'Làm ơn', 'th': 'โปรด', 'id': 'Tolong',
    },
    'I love you': {
      'es': 'Te amo', 'fr': 'Je t\'aime', 'de': 'Ich liebe dich',
      'it': 'Ti amo', 'pt': 'Eu te amo', 'hi': 'मैं तुमसे प्यार करता हूँ',
      'ja': '愛してる', 'zh': '我爱你', 'ar': 'أحبك',
      'ko': '사랑해요', 'ru': 'Я тебя люблю', 'tr': 'Seni seviyorum',
      'nl': 'Ik hou van je', 'sv': 'Jag älskar dig', 'pl': 'Kocham cię',
      'vi': 'Anh yêu em', 'th': 'ฉันรักคุณ', 'id': 'Aku cinta kamu',
    },
    'Help': {
      'es': 'Ayuda', 'fr': 'Aide', 'de': 'Hilfe', 'it': 'Aiuto',
      'pt': 'Ajuda', 'hi': 'मदद', 'ja': '助けて', 'zh': '帮助',
      'ar': 'مساعدة', 'ko': '도움', 'ru': 'Помощь', 'tr': 'Yardım',
      'nl': 'Hulp', 'sv': 'Hjälp', 'pl': 'Pomoc', 'vi': 'Giúp đỡ',
      'th': 'ช่วยด้วย', 'id': 'Tolong',
    },
    'Welcome': {
      'es': 'Bienvenido', 'fr': 'Bienvenue', 'de': 'Willkommen',
      'it': 'Benvenuto', 'pt': 'Bem-vindo', 'hi': 'स्वागत है',
      'ja': 'ようこそ', 'zh': '欢迎', 'ar': 'أهلاً وسهلاً',
      'ko': '환영합니다', 'ru': 'Добро пожаловать', 'tr': 'Hoş geldiniz',
      'nl': 'Welkom', 'sv': 'Välkommen', 'pl': 'Witamy',
      'vi': 'Chào mừng', 'th': 'ยินดีต้อนรับ', 'id': 'Selamat datang',
    },
    'How much': {
      'es': '¿Cuánto cuesta?', 'fr': 'Combien ça coûte?', 'de': 'Wie viel kostet das?',
      'it': 'Quanto costa?', 'pt': 'Quanto custa?', 'hi': 'कितना है?',
      'ja': 'いくらですか？', 'zh': '多少钱？', 'ar': 'كم السعر؟',
      'ko': '얼마예요?', 'ru': 'Сколько стоит?', 'tr': 'Ne kadar?',
      'nl': 'Hoeveel kost het?', 'sv': 'Hur mycket kostar det?', 'pl': 'Ile to kosztuje?',
      'vi': 'Bao nhiêu?', 'th': 'เท่าไหร่?', 'id': 'Berapa?',
    },
    'Where': {
      'es': '¿Dónde?', 'fr': 'Où?', 'de': 'Wo?', 'it': 'Dove?',
      'pt': 'Onde?', 'hi': 'कहाँ?', 'ja': 'どこ？', 'zh': '在哪里？',
      'ar': 'أين؟', 'ko': '어디?', 'ru': 'Где?', 'tr': 'Nerede?',
      'nl': 'Waar?', 'sv': 'Var?', 'pl': 'Gdzie?', 'vi': 'Ở đâu?',
      'th': 'ที่ไหน?', 'id': 'Di mana?',
    },
    'When': {
      'es': '¿Cuándo?', 'fr': 'Quand?', 'de': 'Wann?', 'it': 'Quando?',
      'pt': 'Quando?', 'hi': 'कब?', 'ja': 'いつ？', 'zh': '什么时候？',
      'ar': 'متى؟', 'ko': '언제?', 'ru': 'Когда?', 'tr': 'Ne zaman?',
      'nl': 'Wanneer?', 'sv': 'När?', 'pl': 'Kiedy?', 'vi': 'Khi nào?',
      'th': 'เมื่อไหร่?', 'id': 'Kapan?',
    },
    'Delicious': {
      'es': 'Delicioso', 'fr': 'Délicieux', 'de': 'Lecker',
      'it': 'Delizioso', 'pt': 'Delicioso', 'hi': 'स्वादिष्ट',
      'ja': '美味しい', 'zh': '好吃', 'ar': 'لذيذ',
      'ko': '맛있어요', 'ru': 'Вкусно', 'tr': 'Lezzetli',
      'nl': 'Heerlijk', 'sv': 'Utmärkt', 'pl': 'Pyszne',
      'vi': 'Ngon', 'th': 'อร่อย', 'id': 'Lezat',
    },
    'Beautiful': {
      'es': 'Hermoso', 'fr': 'Beau', 'de': 'Schön', 'it': 'Bello',
      'pt': 'Lindo', 'hi': 'सुंदर', 'ja': '美しい', 'zh': '美丽',
      'ar': 'جميل', 'ko': '아름다워요', 'ru': 'Красивый',
      'tr': 'Güzel', 'nl': 'Mooi', 'sv': 'Vacker', 'pl': 'Piękny',
      'vi': 'Đẹp', 'th': 'สวย', 'id': 'Cantik',
    },
  };

  static const List<Map<String, String>> languages = [
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'hi', 'name': 'Hindi'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'tr', 'name': 'Turkish'},
    {'code': 'nl', 'name': 'Dutch'},
    {'code': 'sv', 'name': 'Swedish'},
    {'code': 'pl', 'name': 'Polish'},
    {'code': 'vi', 'name': 'Vietnamese'},
    {'code': 'th', 'name': 'Thai'},
    {'code': 'id', 'name': 'Indonesian'},
  ];

  static String translate(String text, String targetLang) {
    if (targetLang == 'en') return text;
    for (final entry in _translations.entries) {
      if (text.toLowerCase().contains(entry.key.toLowerCase())) {
        final translation = entry.value[targetLang];
        if (translation != null) return translation;
      }
    }
    return '[${_langName(targetLang)}] $text';
  }

  static String detectLang(String text) {
    for (final entry in _translations.entries) {
      for (final langEntry in entry.value.entries) {
        if (text.contains(langEntry.value)) return langEntry.key;
      }
    }
    return 'en';
  }

  static String _langName(String code) {
    final langs = {
      'es': 'ES', 'fr': 'FR', 'de': 'DE', 'it': 'IT', 'pt': 'PT',
      'hi': 'HI', 'ja': 'JA', 'zh': 'ZH', 'ar': 'AR', 'ko': 'KO',
      'ru': 'RU', 'tr': 'TR', 'nl': 'NL', 'sv': 'SV', 'pl': 'PL',
      'vi': 'VI', 'th': 'TH', 'id': 'ID',
    };
    return langs[code] ?? code.toUpperCase();
  }
}

class SmartReplyService {
  static List<String> getSuggestions(String lastMessage) {
    final msg = lastMessage.toLowerCase();

    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey') || msg.contains('yo')) {
      return ['Hey!', 'Hello there!', 'Hi, how are you?', 'Yo!'];
    }
    if (msg.contains('how are you') || msg.contains('how\'s it going') || msg.contains('how do you do')) {
      return ['I\'m good, thanks!', 'Doing well!', 'Great, you?', 'All good!'];
    }
    if (msg.contains('thank') || msg.contains('thanks') || msg.contains('ty ')) {
      return ['You\'re welcome!', 'No problem!', 'Anytime!', 'My pleasure!'];
    }
    if (msg.contains('yes') || msg.contains('yeah') || msg.contains('sure') || msg.contains('yep')) {
      return ['Great!', 'Awesome!', 'Let\'s do it!', 'Perfect!'];
    }
    if (msg.contains('no') || msg.contains('nah') || msg.contains('nope') || msg.contains('never')) {
      return ['Okay', 'No problem', 'Maybe later?', 'Alright'];
    }
    if (msg.contains('bye') || msg.contains('goodbye') || msg.contains('see you') || msg.contains('cya') || msg.contains('ttyl')) {
      return ['Goodbye!', 'See you later!', 'Take care!', 'Cya!'];
    }
    if (msg.contains('lol') || msg.contains('haha') || msg.contains('😂') || msg.contains('lmao') || msg.contains('lmfao')) {
      return ['😂😂', 'Same lol', 'Haha fr', 'Dead 💀'];
    }
    if (msg.contains('ok') || msg.contains('okay') || msg.contains('k ') || msg.contains('kk')) {
      return ['Cool', 'Sounds good', '👍', 'Bet!'];
    }
    if (msg.contains('what') || msg.contains('where') || msg.contains('when') || msg.contains('who') || msg.contains('why')) {
      return ['I don\'t know', 'Let me check', 'Maybe?', 'Good question'];
    }
    if (msg.contains('love') || msg.contains('❤️') || msg.contains('💕') || msg.contains('miss')) {
      return ['❤️', 'Love you too!', '🥰', 'Miss you too!'];
    }
    if (msg.contains('time') || msg.contains('late') || msg.contains('early') || msg.contains('minute')) {
      return ['What time?', 'I\'m on my way', 'Soon', 'Give me 5 mins'];
    }
    if (msg.contains('meet') || msg.contains('come') || msg.contains('go') || msg.contains('arrive')) {
      return ['Where?', 'When?', 'Sure!', 'On my way!'];
    }
    if (msg.contains('call') || msg.contains('phone') || msg.contains('ring') || msg.contains('facetime')) {
      return ['Calling now', 'I\'ll call you', 'Okay', 'Can\'t talk rn'];
    }
    if (msg.contains('food') || msg.contains('eat') || msg.contains('hungry') || msg.contains('dinner') || msg.contains('lunch')) {
      return ['Let\'s eat!', 'I\'m hungry too', 'What do you want?', 'Ordering now'];
    }
    if (msg.contains('sleep') || msg.contains('tired') || msg.contains('bed') || msg.contains('nap')) {
      return ['Good night!', 'Sleep well!', 'Sweet dreams!', 'Get some rest'];
    }
    if (msg.contains('sorry') || msg.contains('apologize') || msg.contains('my bad') || msg.contains('forgive')) {
      return ['No worries!', 'It\'s okay', 'Don\'t worry about it', 'All good!'];
    }
    if (msg.contains('congrats') || msg.contains('congratulations') || msg.contains('well done') || msg.contains('proud')) {
      return ['Thank you!', 'Thanks so much!', 'Appreciate it!', '🎉'];
    }
    if (msg.contains('weather') || msg.contains('rain') || msg.contains('sunny') || msg.contains('cold') || msg.contains('hot')) {
      return ['I know right!', 'Crazy weather', 'Stay safe!', 'Bring an umbrella'];
    }
    if (msg.contains('work') || msg.contains('job') || msg.contains('office') || msg.contains('busy')) {
      return ['Good luck!', 'You got this!', 'Take your time', 'Work hard!'];
    }
    if (msg.contains('party') || msg.contains('fun') || msg.contains('weekend') || msg.contains('tonight')) {
      return ['Sounds fun!', 'I\'m in!', 'What time?', 'Let\'s go!'];
    }
    if (msg.contains('wait') || msg.contains('hold on') || msg.contains('brb') || msg.contains('one sec')) {
      return ['Take your time', 'I\'ll wait', 'Kk', 'No rush'];
    }
    if (msg.contains('wow') || msg.contains('omg') || msg.contains('no way') || msg.contains('really') || msg.contains('omfg')) {
      return ['I know right!', 'Crazy!', 'No way!', 'Fr fr'];
    }
    if (msg.contains('morning') || msg.contains('afternoon') || msg.contains('evening')) {
      return ['Good morning!', 'Have a great day!', 'Good afternoon!', 'Good evening!'];
    }

    return ['Okay', 'Interesting', 'I see', 'For real?', 'Tell me more'];
  }
}
