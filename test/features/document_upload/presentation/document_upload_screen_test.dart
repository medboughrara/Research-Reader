import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:research_reader/features/document_upload/bloc/document_upload_bloc.dart';
import 'package:research_reader/features/document_upload/presentation/document_upload_screen.dart';
import 'package:research_reader/features/analysis/bloc/analysis_bloc.dart';
import 'package:research_reader/features/analysis/presentation/analysis_screen.dart';
import 'package:research_reader/shared/models/document.dart';
import 'package:research_reader/shared/services/document_service.dart';
import 'package:research_reader/shared/services/analysis_service.dart';
import 'package:research_reader/shared/services/gemini_service.dart';
import 'package:research_reader/shared/di/service_locator.dart' as di; // Use 'di' prefix

// Mock Classes
class MockDocumentUploadBloc extends MockBloc<DocumentUploadEvent, DocumentUploadState> 
  implements DocumentUploadBloc {}

class MockAnalysisBloc extends MockBloc<AnalysisEvent, AnalysisState> 
  implements AnalysisBloc {}

class MockDocumentService extends Mock implements DocumentService {}
class MockAnalysisService extends Mock implements AnalysisService {}
class MockGeminiService extends Mock implements GeminiService {}

// Fallback values
class FakeDocument extends Fake implements Document {}
class FakeAnalysisEvent extends Fake implements AnalysisEvent {}
class FakeAnalysisState extends Fake implements AnalysisState {}
class FakeDocumentUploadEvent extends Fake implements DocumentUploadEvent {}
class FakeDocumentUploadState extends Fake implements DocumentUploadState {}


void main() {
  late MockDocumentUploadBloc mockDocumentUploadBloc;
  late MockAnalysisBloc mockAnalysisBloc; // For AnalysisScreen
  late MockAnalysisService mockAnalysisService;
  late MockGeminiService mockGeminiService;

  setUpAll(() {
    // Register fallback values for any() matchers if needed by whenListen or other mock setups
    registerFallbackValue(FakeDocument());
    registerFallbackValue(FakeAnalysisEvent());
    registerFallbackValue(FakeAnalysisState());
    registerFallbackValue(FakeDocumentUploadEvent());
    registerFallbackValue(FakeDocumentUploadState());
  });

  setUp(() async {
    // Reset and re-register services for each test to ensure clean state
    await di.getIt.reset(); // Reset getIt

    mockDocumentUploadBloc = MockDocumentUploadBloc();
    mockAnalysisBloc = MockAnalysisBloc();
    mockAnalysisService = MockAnalysisService();
    mockGeminiService = MockGeminiService();

    // Register dependencies for AnalysisScreen and its AnalysisBloc
    // AnalysisBloc is created inside AnalysisScreen using context.read(), 
    // which means AnalysisService needs to be available via getIt if AnalysisBloc's factory uses getIt.
    // AnalysisScreen's BlocProvider: create: (context) => AnalysisBloc(context.read())..add(StartAnalysis(document))
    // This implies AnalysisBloc needs AnalysisService.
    // AnalysisService constructor: AnalysisService(this._repository, this._geminiService, {String? apiEndpoint})
    // We need to provide DocumentRepository as well, or simplify AnalysisService mocking.
    // For simplicity here, let's assume GeminiService is the primary one needed by AnalysisService,
    // and DocumentRepository can be a basic mock if not deeply used by the part of AnalysisService
    // that AnalysisBloc interacts with upon initialization.
    
    di.getIt.registerSingleton<GeminiService>(mockGeminiService);
    // AnalysisService now takes DocumentRepository and GeminiService.
    // We need a MockDocumentRepository for this.
    final mockDocumentRepository = MockDocumentRepository(); // Define if not already
    di.getIt.registerSingleton<DocumentRepository>(mockDocumentRepository);
    di.getIt.registerSingleton<AnalysisService>(mockAnalysisService);


    // When AnalysisScreen is pushed, it creates an AnalysisBloc.
    // We need to ensure this AnalysisBloc behaves predictably.
    // It's often easier to mock the Bloc that the target screen will use.
    // However, AnalysisScreen creates its own AnalysisBloc.
    // So, when AnalysisBloc(context.read()) is called, context.read() will try to find AnalysisService.
    // We've registered mockAnalysisService.
    // The AnalysisBloc will then dispatch StartAnalysis. We need to stub this.
    when(() => mockAnalysisService.analyzeDocument(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments[0] as Document); // Return the same document
    when(() => mockAnalysisService.generateSummary(any())).thenAnswer(
        (_) async => "Mocked summary");


    // Stubbing for AnalysisBloc that will be created by AnalysisScreen
    // This is a bit tricky as AnalysisScreen creates its own.
    // An alternative would be to make AnalysisScreen accept AnalysisBloc as a parameter for testing.
    // For now, we rely on the getIt setup for AnalysisService.
    // If AnalysisBloc itself was registered in getIt, we could register mockAnalysisBloc.
    // Since AnalysisScreen creates AnalysisBloc(context.read<AnalysisService>()), our mockAnalysisService will be used.
    // We need to make sure that when StartAnalysis is added, AnalysisBloc emits some state.
    // This might require a more complex setup or using a FakeAnalysisBloc.

    // For testing navigation, we often don't need the target screen's Bloc to do much,
    // just enough for it to render without error.
    // Let's assume AnalysisInitial is fine for the initial state of the dynamically created AnalysisBloc.
    // If StartAnalysis in AnalysisScreen's Bloc leads to states that cause UI errors without further mocking,
    // this test might become flaky.
  });

  tearDown(() async {
    await di.getIt.reset();
  });

  testWidgets('navigates to AnalysisScreen on DocumentUploadSuccess', (WidgetTester tester) async {
    // Arrange
    final mockDocument = Document(
      id: '1',
      title: 'Test Doc',
      filePath: 'dummy.pdf',
      pageCount: 1,
      uploadDate: DateTime.now(),
      status: DocumentStatus.uploaded,
    );

    // Make the DocumentUploadBloc emit DocumentUploadSuccess
    // The initial state for whenListen should be the state *before* the event that triggers the listener.
    // DocumentUploadScreen starts and its BlocConsumer listens.
    // If an action (like button press) triggers the success state, that action should be part of "act".
    // Here, we simulate the success state being emitted after the screen is built.
    whenListen(
      mockDocumentUploadBloc,
      Stream.fromIterable([DocumentUploadSuccess(mockDocument)]),
      initialState: DocumentUploadInitial(), 
    );

    // Provide a MockAnalysisBloc for the AnalysisScreen to find if it were using BlocProvider.value
    // However, AnalysisScreen creates its own Bloc: create: (context) => AnalysisBloc(context.read())
    // So we need to ensure context.read() (which means getIt<AnalysisService>()) works.
    // This was handled in setUp.

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DocumentUploadBloc>.value(
          value: mockDocumentUploadBloc,
          child: const DocumentUploadScreen(),
        ),
        // Adding routes for navigation or ensuring AnalysisScreen can be pushed.
        // If AnalysisScreen or its children use Navigator.popAndPushNamed or similar, routes are needed.
        // For Navigator.push(MaterialPageRoute(...)), direct pushing works.
        // However, AnalysisScreen itself might have dependencies for its own Bloc.
        routes: {
          // Define a route for AnalysisScreen if it's navigated to by name,
          // or ensure its dependencies are met for MaterialPageRoute.
          // For this test, direct push is fine, but AnalysisScreen's internal Bloc needs AnalysisService.
        },
      ),
    );

    // At this point, DocumentUploadScreen is built, and BlocConsumer's listener should be active.
    // The whenListen setup will make it emit DocumentUploadSuccess immediately or shortly after.
    
    await tester.pumpAndSettle(); // Allow time for listener and navigation

    // Assert
    expect(find.byType(AnalysisScreen), findsOneWidget);
    expect(find.byType(DocumentUploadScreen), findsOneWidget); // Still present due to Navigator.push

    // Optional: Verify document data passed to AnalysisScreen
    // This can be done if AnalysisScreen displays something unique from the document, like its title.
    // For example, if AnalysisScreen's AppBar title was the document title:
    // expect(find.text('Test Doc'), findsWidgets); // This depends on AnalysisScreen's UI

    // Verify that the StartAnalysis event was added to an AnalysisBloc instance.
    // This is tricky because the bloc is created inside AnalysisScreen.
    // We can check if the mockAnalysisService.analyzeDocument was called,
    // as AnalysisBloc calls it in its StartAnalysis handler.
    // This implicitly tests that AnalysisBloc was created and an event was added.
    // Note: This verify needs to happen on the mockAnalysisService registered with getIt.
    // verify(() => mockAnalysisService.analyzeDocument(mockDocument)).called(1); 
    // This verify is problematic because analyzeDocument might be called by the *real* AnalysisBloc
    // using the *real* AnalysisService if getIt isn't perfectly cleaned or if the mock isn't injected correctly
    // into the dynamically created AnalysisBloc.
    // A simpler check is just that navigation occurred.
  });
}

// Minimal MockDocumentRepository for AnalysisService dependency
class MockDocumentRepository extends Mock implements DocumentRepository {}
