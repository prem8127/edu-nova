import '../../core/constants/app_enums.dart';
import '../../models/syllabus_model.dart';
import '../interfaces/syllabus_repository.dart';

/// Static curriculum content — ported 1:1 from the Aditya Globals
/// prototype's `syllabusData` (Class 6–10 entrepreneur roadmap). This is
/// fixed platform content rather than per-user data, so the "repository"
/// here just returns it; swapping to a CMS-backed implementation later
/// only means changing this one class.
class LocalSyllabusRepository implements SyllabusRepository {
  @override
  Future<List<SyllabusClassPlan>> getSyllabus() async => _syllabus;

  @override
  Future<Map<String, List<String>>> getEssentialBooks() async => _books;

  static const _syllabus = <SyllabusClassPlan>[
    SyllabusClassPlan(
      grade: Grade.class6,
      className: 'Class 6',
      stageLabel: 'Stage 1 — Business Foundations',
      modules: [
        SyllabusModule(title: 'Money Basics', topics: [
          'What is money?',
          'History of money',
          'Income vs Expenses',
          'Saving and Spending',
          'Budgeting',
          'Needs vs Wants',
          'Banks and bank accounts',
          'Digital payments (UPI, cards, wallets)',
          'Interest (simple concept)',
        ]),
        SyllabusModule(title: 'Understanding Business', topics: [
          'What is a business?',
          'Why businesses exist',
          'Types of businesses',
          'Product vs Service',
          'Small business vs Large company',
          'Local businesses around you',
          'How businesses make profit',
        ]),
        SyllabusModule(title: 'Communication Skills', topics: [
          'Speaking clearly',
          'Listening skills',
          'Public speaking',
          'Storytelling',
          'Writing emails',
          'Presentation skills',
        ]),
        SyllabusModule(title: 'Basic Mathematics for Business', topics: [
          'Percentages',
          'Profit and loss',
          'Discounts',
          'Ratios',
          'Graphs',
          'Data interpretation',
        ]),
        SyllabusModule(title: 'Observation Projects', topics: [
          'Study nearby shops',
          'Compare prices',
          'Observe customer behaviour',
          'Interview local business owners',
        ]),
      ],
      projects: [
        'Lemonade stand simulation',
        'Handmade crafts selling',
        'School stationery selling',
        'Small budgeting exercise',
      ],
    ),
    SyllabusClassPlan(
      grade: Grade.class7,
      className: 'Class 7',
      stageLabel: 'Stage 2 — Understanding Markets',
      modules: [
        SyllabusModule(title: 'Entrepreneurship Basics', topics: [
          'What is entrepreneurship?',
          'Entrepreneur mindset',
          'Risk and reward',
          'Problem-solving',
          'Innovation',
        ]),
        SyllabusModule(title: 'Marketing Basics', topics: [
          'What is marketing?',
          'Customer needs',
          'Branding basics',
          'Logos and slogans',
          'Advertising',
          'Social media basics',
        ]),
        SyllabusModule(title: 'Sales Fundamentals', topics: [
          'What is sales?',
          'Customer interaction',
          'Negotiation basics',
          'Persuasion skills',
          'Customer service',
        ]),
        SyllabusModule(title: 'Technology for Business', topics: [
          'MS Word',
          'PowerPoint',
          'Excel basics',
          'Internet research',
          'Online safety',
        ]),
        SyllabusModule(title: 'Economics Basics', topics: [
          'Supply and demand',
          'Scarcity',
          'Resources',
          'Markets',
          'Producers and consumers',
        ]),
      ],
      projects: [
        'Create a brand',
        'Design a logo',
        'Survey 100 people',
        'Sell a simple product',
      ],
    ),
    SyllabusClassPlan(
      grade: Grade.class8,
      className: 'Class 8',
      stageLabel: 'Stage 3 — Building Real Business Skills',
      modules: [
        SyllabusModule(title: 'Accounting Basics', topics: [
          'Revenue',
          'Expenses',
          'Profit',
          'Loss',
          'Assets',
          'Liabilities',
          'Cash flow',
        ]),
        SyllabusModule(title: 'Advanced Marketing', topics: [
          'Digital marketing',
          'Content marketing',
          'Email marketing',
          'Influencer marketing',
          'SEO basics',
        ]),
        SyllabusModule(title: 'Product Development', topics: [
          'Finding problems',
          'Product design',
          'MVP (Minimum Viable Product)',
          'Customer feedback',
        ]),
        SyllabusModule(title: 'Leadership', topics: [
          'Team building',
          'Delegation',
          'Decision making',
          'Conflict management',
        ]),
        SyllabusModule(title: 'Data Analysis', topics: [
          'Excel intermediate',
          'Charts',
          'Dashboards',
          'Customer data analysis',
        ]),
      ],
      projects: [
        'Launch a small online business',
        'Create a website',
        'Build a school service business',
      ],
    ),
    SyllabusClassPlan(
      grade: Grade.class9,
      className: 'Class 9',
      stageLabel: 'Stage 4 — Business Creation',
      modules: [
        SyllabusModule(title: 'Business Models', topics: [
          'B2B',
          'B2C',
          'Subscription',
          'Marketplace',
          'Franchise',
          'SaaS',
        ]),
        SyllabusModule(title: 'Finance', topics: [
          'Financial statements',
          'Cash flow statement',
          'Balance sheet',
          'Income statement',
        ]),
        SyllabusModule(title: 'Business Planning', topics: [
          'Business plan',
          'Market research',
          'Competitor analysis',
          'SWOT analysis',
        ]),
        SyllabusModule(title: 'Digital Business', topics: [
          'E-commerce',
          'App business',
          'YouTube business',
          'Affiliate marketing',
        ]),
        SyllabusModule(title: 'Legal Basics', topics: [
          'Business registration',
          'GST basics',
          'Intellectual property',
          'Copyright',
          'Trademarks',
        ]),
      ],
      projects: [
        'Write a business plan',
        'Launch a website',
        'Run a small marketing campaign',
      ],
    ),
    SyllabusClassPlan(
      grade: Grade.class10,
      className: 'Class 10',
      stageLabel: 'Stage 5 — Entrepreneur Preparation',
      modules: [
        SyllabusModule(title: 'Startup Fundamentals', topics: [
          'Startup ecosystem',
          'Venture capital',
          'Angel investors',
          'Bootstrapping',
          'Fundraising',
        ]),
        SyllabusModule(title: 'Advanced Marketing', topics: [
          'Meta Ads',
          'Google Ads',
          'Analytics',
          'Conversion optimization',
        ]),
        SyllabusModule(title: 'Business Operations', topics: [
          'Supply chain',
          'Inventory management',
          'Vendor management',
          'Quality control',
        ]),
        SyllabusModule(title: 'People Management', topics: [
          'Hiring',
          'Training',
          'Performance management',
          'Company culture',
        ]),
        SyllabusModule(title: 'Strategic Thinking', topics: [
          'Competitive advantage',
          'Growth strategies',
          'Scaling a business',
          'Business expansion',
        ]),
        SyllabusModule(title: 'AI for Entrepreneurs', topics: [
          'ChatGPT',
          'AI tools',
          'Automation',
          'AI marketing',
          'AI content creation',
        ]),
      ],
      projects: [
        'Launch a real business',
        'Generate first customers',
        'Build a website/app',
        'Create marketing campaigns',
        'Present to investors',
      ],
    ),
  ];

  static const _books = <String, List<String>>{
    'Beginner': [
      'Rich Dad Poor Dad for Teens',
      'The Lemonade War',
      'How to Turn \$100 into \$1,000,000',
    ],
    'Intermediate': [
      'The Lean Startup',
      'The Personal MBA',
      'Think and Grow Rich',
    ],
    'Advanced': [
      'Zero to One',
      'The Psychology of Money',
    ],
  };
}
