# FACTUAL - Application Description
## Comprehensive App Overview & Specifications

---

## 📱 BASIC INFORMATION

| Field | Value |
|-------|-------|
| **Application Name** | factual |
| **Version** | 1.0 |
| **Category** | Productivity |
| **Course** | Human-Computer Interaction (HCI) |
| **Semester** | 7th Semester - National Technical University of Athens (NTUA) |
| **Institution** | School of Electrical & Computer Engineers |
| **Submission Date** | April 11, 2025 |

---

## 👥 DEVELOPMENT TEAM

| Role | Name | Student ID |
|------|------|-----------|
| Developer | Χρήστος Λαδιάς (Christos Ladias) | 03116307 |
| Developer | Παντελεήμων Αγγελίδης (Panteleimon Angelidis) | 3123728 |

---

## 🎯 APPLICATION OVERVIEW

### Promotional Text / Punchline

> **"An open-source tool to enhance the fact-checking process. Cross validate sources, detect and assess news reproductions, see what insights other users are looking for."**

### Full Description

**factual** is an essential tool for the modern news reporter. In a world where media outlets are increasingly being censored and controlled, independent and truly unbiased journalism is being threatened. 

With **Factual**, you can review how news are being reported throughout the world from different sources, all easily and fast from your phone.

---

## 🎯 PRIMARY OBJECTIVES

**Problem Statement:**
- Media monopolization and censorship threatening independent journalism
- Difficulty in cross-validating news sources quickly
- Need for unbiased, comprehensive news verification
- Lack of easy-to-use fact-checking tools for reporters on-the-go

**Solution:**
- Provide journalists and news enthusiasts with a mobile-first fact-checking platform
- Enable cross-source validation
- Identify news reproductions and duplicates
- Leverage community insights for collaborative fact-checking
- Make journalism more transparent and trustworthy

---

## 🏗️ CORE FEATURES & FUNCTIONAL REQUIREMENTS

The application is built on **three integrated axes** (pillars), each addressing key HCI concepts:

---

### **AXIS 1: User Modeling & Adaptation (個人化)**

#### User Modeling (Μοντελοποίηση Χρήστη)
- **Feature**: Track past searches per user
- **Purpose**: Build comprehensive user profiles based on search history
- **Storage**: Persistent local/cloud database of user queries

#### Adaptive Recommendations (Προσαρμογή)
- **Geographic-Based Popular Searches**: 
  - Track which searches are popular in specific regions
  - Analyze user location data to provide location-aware popular search trends
  - Display trending topics relevant to user's geographic area

- **Personalized Topic Suggestions**:
  - Based on past search history, suggest topics user might be interested in
  - Use past searches to predict future information needs
  - Provide faster experience with pre-populated relevant topics

- **Push Notifications**:
  - Send proactive notifications about topics matching user's interests
  - Use search history to determine notification relevance
  - Reduce information overload by personalizing notification content

**HCI Principle**: Reduce cognitive load through personalization and anticipatory design

---

### **AXIS 2: Affective Computing & AI-Powered Intelligence (συναισθηματική Υπολογιστική)**

#### Affective Computing (Emotional Context Processing)
- **Challenge**: Implementing emotional assessment of news and user queries
- **Implementation**: 
  - Analyze emotional tone/sentiment of each search query
  - Classify news articles by emotional sentiment
  - Adjust search results and recommendations based on user emotional intent
  - Display content appropriately matched to user's emotional expectations

- **Use Cases**:
  - User searching for "political scandal" vs. "political news" → different emotional contexts
  - Adjust presentation of controversial news based on user sentiment
  - Filter sensationalist vs. factual reporting

**HCI Principle**: Understand user emotional state and context to provide more relevant results

#### AI & Machine Learning (ΑΑΥ και Μηχανική Μάθηση)
- **LLM-Based Agents**:
  - Purpose-fine-tuned Language Models (LLMs) for fact-checking
  - Agent-based architecture for processing natural language queries
  - Custom agents trained for:
    - News source credibility assessment
    - Fact verification
    - Identifying news reproductions/duplicates
    - Cross-source validation

- **Adaptive Machine Learning**:
  - Continuously learn from user interactions
  - Improve fact-checking accuracy based on user feedback
  - Personalize content recommendations
  - Identify emerging patterns in misinformation

- **Natural Language Processing**:
  - Both text and voice input support
  - Voice-to-text conversion (speech input instead of typing)
  - Natural language query understanding
  - Semantic similarity detection between articles

**HCI Principle**: Use AI to augment human capability in information verification

---

### **AXIS 3: Connectivity & Spatio-Temporal Information (Συνδεσιμότητα)**

#### Geographic-Based News Filtering (Χωροχρονική Σύνδεση)
- **Map-Based Interface**:
  - Integrated map view for geographic selection
  - Users can select specific locations/regions
  - Filter news by geographic area of origin/impact

- **Spatio-Temporal Relationships**:
  - Connect news articles that share:
    - **Spatial**: Same geographic location/region
    - **Temporal**: Same time period/time window
    - **Topic**: Related topics from same region
  - Identify coordinated news campaigns across regions
  - Track how stories evolve geographically over time

- **Global News Coverage**:
  - See how the same story is reported differently by sources in different regions
  - Compare reporting quality/bias across geographic boundaries
  - Understand geopolitical context of news coverage

**HCI Principle**: Provide contextual information through geographic and temporal relationships

---

## 🎨 USER INTERFACE DESIGN

### Design Tool
- **Platform**: Figma (collaborative design tool)
- **Status**: Initial wireframes completed
- **Iterations**: Multiple design mockups created

### Key Design Principles
1. **Simplicity**: Clean, intuitive interface for quick news verification
2. **Efficiency**: Fast access to cross-source validation
3. **Transparency**: Show sources and verification status clearly
4. **Accessibility**: Voice input for hands-free operation
5. **Context-Aware**: Map and personalized recommendations visible

### Main User Flows
1. **Quick Verification Flow**:
   - User → Search article → See sources → View verification status
   
2. **Deep Research Flow**:
   - User → Explore map → Select region → View regional coverage → Compare articles
   
3. **Personalized Exploration Flow**:
   - User → View recommendations → See similar past searches → Explore trends

---

## 🔧 TECHNICAL SPECIFICATIONS

### Technology Stack (Recommended)
- **Framework**: Flutter (cross-platform mobile app)
- **Backend**: Node.js / Python (LLM agent servers)
- **AI/ML**: 
  - Google Gemini API / OpenAI GPT for LLM agents
  - TensorFlow / PyTorch for affective computing models
- **Database**: 
  - Firebase Firestore (cloud) or SQLite (local)
  - For user profiles, search history, article cache
- **Maps**: Google Maps API for geographic features
- **Voice**: Speech-to-text API (Google Speech API or similar)

### Key Requirements
1. **Real-time Data**:
   - Live news feeds from multiple sources
   - Real-time user location (with permission)
   - Real-time recommendation updates

2. **Scalability**:
   - Support thousands of simultaneous users
   - Cache frequently searched topics
   - Efficient LLM agent load balancing

3. **Performance**:
   - Search results within 2-3 seconds
   - Smooth map interactions
   - Voice input processing latency < 1 second

4. **Security & Privacy**:
   - Encrypt user search history
   - Comply with GDPR (user data protection)
   - Secure API key management
   - Optional anonymous mode

---

## 📊 DATA FLOW

```
User Input
    ↓
[Text / Voice Search]
    ↓
LLM Agent Processing
├─ Sentiment Analysis
├─ Intent Classification
└─ Query Enhancement
    ↓
Database Query
├─ Local article cache
├─ User preferences
└─ Geographic filters
    ↓
News Source Integration
├─ Multiple news APIs
├─ Web scraping
└─ RSS feeds
    ↓
AI Processing
├─ Credibility Assessment
├─ Duplicate Detection
├─ Sentiment Extraction
└─ Geographic Tagging
    ↓
Personalization Layer
├─ User profile matching
├─ Affective adjustment
└─ Recommendation ranking
    ↓
Results Display
├─ Source cards
├─ Map visualization
└─ Related articles
    ↓
User Feedback
└─ Update models & personalization
```

---

## 🎯 KEY FEATURES SUMMARY

| Feature | Category | Description | HCI Axis |
|---------|----------|-------------|----------|
| **Cross-Source Validation** | Core | Compare same news across multiple sources | All |
| **Duplicate Detection** | Core | Identify reproductions and plagiarism | Axis 2 |
| **Geographic Filtering** | Core | Filter by location on interactive map | Axis 3 |
| **Sentiment Analysis** | Affective | Emotional context of articles | Axis 2 |
| **Voice Search** | AI | Speech-to-text news search | Axis 2 |
| **Past Searches** | Personalization | History-based recommendations | Axis 1 |
| **Popular Searches** | Personalization | Regional trending topics | Axis 1 |
| **Push Notifications** | Engagement | Interest-based news alerts | Axis 1 |
| **User Modeling** | Intelligence | Personalized search profiles | Axis 1 |
| **LLM Agents** | Intelligence | Fine-tuned fact-checking models | Axis 2 |

---

## 🌟 UNIQUE VALUE PROPOSITION

### Why factual is different from existing solutions:

1. **Mobile-First Design**: Optimize for on-the-go journalists
2. **Open-Source**: Community-driven fact-checking
3. **Geographic Intelligence**: Understand local reporting patterns
4. **Emotional Context**: Beyond just facts to understanding bias
5. **User Collaborative**: See what other journalists are investigating
6. **AI-Powered**: LLM agents for intelligent verification
7. **Cross-Platform**: Consistent experience across devices

---

## 🎓 HCI LEARNING OUTCOMES

### Addressed HCI Concepts

**Axis 1 - User Modeling:**
- Personalization based on interaction history
- Anticipatory interface design
- Adaptive information display

**Axis 2 - Affective Computing & AI:**
- Emotional context understanding
- Natural language processing
- Machine learning integration
- Voice interface design

**Axis 3 - Connectivity:**
- Spatio-temporal information visualization
- Geographic context in information design
- Location-based personalization

---

## 📱 USER PERSONAS

### 1. Independent Journalist
- **Goal**: Verify stories quickly across multiple sources
- **Pain Point**: Limited time, need fast verification
- **Usage**: Daily fact-checking during story research
- **Key Feature**: Cross-source validation, voice search

### 2. News Consumer
- **Goal**: Understand reporting bias
- **Pain Point**: Information overload, unclear sources
- **Usage**: Weekly news consumption
- **Key Feature**: Geographic comparison, sentiment analysis

### 3. Fact-Check Organization
- **Goal**: Identify misinformation patterns
- **Pain Point**: Manual cross-checking is slow
- **Usage**: Continuous monitoring
- **Key Feature**: Automated detection, collaboration

### 4. Academic Researcher
- **Goal**: Study media bias and coverage patterns
- **Pain Point**: Need structured data about reporting
- **Usage**: Long-term analysis
- **Key Feature**: Data export, geographic analysis

---

## 🚀 DEPLOYMENT & DISTRIBUTION

- **Platform**: Google Play Store, Apple App Store
- **Category**: Productivity
- **Target Audience**: Journalists, news professionals, informed citizens
- **Availability**: Global (initially English, expandable to multiple languages)

---

## 📋 DELIVERABLES (PHASE 3)

As part of Phase 3 implementation:

✓ Fully functional Flutter application  
✓ Integrated LLM agents for fact-checking  
✓ Data persistence across sessions  
✓ Map-based geographic interface  
✓ Voice input capability  
✓ User search history tracking  
✓ Personalized recommendations  
✓ Cross-source news validation  
✓ Comprehensive README documentation  
✓ Working APK for Android devices  

---

## 📅 PROJECT TIMELINE

| Phase | Focus | Status |
|-------|-------|--------|
| **Phase 1** | Concept & Prototyping | ✓ Complete |
| **Phase 2** | Wireframes & UI Design | ✓ Complete |
| **Phase 3** | Full Implementation | 🔄 In Progress |
| **Phase 4** | Testing & Deployment | ⏳ Pending |

---

## 📖 DOCUMENTATION

This app description should be read alongside:

- **Flutter-Phase-3-Instructions.md** - Technical implementation guide
- **Phase-3-Code-Reference.md** - Code patterns and examples
- **Phase-3-Task-Breakdown.md** - Detailed task list and dependencies
- **Phase-3-Visual-Guide.md** - Visual flowcharts and checklists

---

## 🔗 REFERENCES & RESOURCES

### News Aggregation APIs
- News API (newsapi.org)
- Guardian API
- NYT API
- MediaStack

### LLM Services
- Google Gemini API
- OpenAI GPT-4
- Anthropic Claude
- Open-source models (Llama, Mistral)

### Maps & Location
- Google Maps API
- Mapbox
- OpenStreetMap

### Speech Processing
- Google Cloud Speech-to-Text
- Azure Speech Services
- Whisper (OpenAI)

### Sentiment Analysis
- VADER (NLTK)
- Transformers (Hugging Face)
- spaCy NLP
- TextBlob

---

## ✅ ACCEPTANCE CRITERIA

The application will be considered successful if:

1. ✓ All three HCI axes are implemented
2. ✓ Cross-source news validation functional
3. ✓ Geographic filtering with map interface
4. ✓ Personalized recommendations working
5. ✓ Voice input operational
6. ✓ LLM agents processing queries
7. ✓ Data persists across app sessions
8. ✓ APK builds and installs successfully
9. ✓ Comprehensive documentation provided
10. ✓ Performance meets target latencies

---

## 📞 CONTACT & SUPPORT

**Project Team:**
- Christos Ladias: 03116307@ntua.gr
- Panteleimon Angelidis: 3123728@ntua.gr

**Institution:**
- National Technical University of Athens (NTUA)
- School of Electrical & Computer Engineers
- Human-Computer Interaction Course

---

**Document Version**: 1.0  
**Created**: January 13, 2026  
**Last Updated**: January 13, 2026  
**Status**: READY FOR PHASE 3 IMPLEMENTATION

---

## 🎯 NEXT STEPS

Proceed to implement this application using:

1. **Flutter-Phase-3-Instructions.md** - Complete requirements breakdown
2. **Phase-3-Code-Reference.md** - Ready-to-use code examples
3. **Phase-3-Task-Breakdown.md** - Atomic implementation tasks
4. **Phase-3-Visual-Guide.md** - Visual guidance and checklists

**Remember**: Deadline is **February 7, 2025**. Ensure all external services remain active until evaluation.

---

**Good luck with the factual application! This is an exciting project with real-world impact for journalism and media integrity.** 🚀
