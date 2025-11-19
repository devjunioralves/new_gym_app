import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_gym_app/features/auth/presentation/screens/login_screen.dart';
import 'package:new_gym_app/features/auth/presentation/screens/register_screen.dart';
import 'package:new_gym_app/features/exercise_detail/presentation/screens/exercise_detail_screen.dart';
import 'package:new_gym_app/features/home/presentation/screens/home_screen.dart';
import 'package:new_gym_app/features/manage_exercises/presentation/screens/create_exercise_screen.dart';
import 'package:new_gym_app/features/manage_exercises/presentation/screens/exercises_library_screen.dart';
import 'package:new_gym_app/features/manage_exercises/presentation/screens/manage_exercises_screen.dart';
import 'package:new_gym_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:new_gym_app/features/students/presentation/screens/create_workout_screen.dart';
import 'package:new_gym_app/features/students/presentation/screens/edit_workout_screen.dart';
import 'package:new_gym_app/features/students/presentation/screens/register_student_screen.dart';
import 'package:new_gym_app/features/students/presentation/screens/student_detail_screen.dart';
import 'package:new_gym_app/features/students/presentation/screens/students_list_screen.dart';
import 'package:new_gym_app/features/students/presentation/screens/workout_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/exercises-library',
        builder: (context, state) => const ExercisesLibraryScreen(),
      ),
      GoRoute(
        path: '/manage-exercises',
        builder: (context, state) => const ManageExercisesScreen(),
      ),
      GoRoute(
        path: '/create-exercise',
        builder: (context, state) => const CreateExerciseScreen(),
      ),
      GoRoute(
        path: '/students',
        builder: (context, state) => const StudentsListScreen(),
      ),
      GoRoute(
        path: '/register-student',
        builder: (context, state) => const RegisterStudentScreen(),
      ),
      GoRoute(
        path: '/student-detail/:studentId',
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          return StudentDetailScreen(studentId: studentId);
        },
      ),
      GoRoute(
        path: '/create-workout/:studentId',
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          return CreateWorkoutScreen(studentId: studentId);
        },
      ),
      GoRoute(
        path: '/edit-workout/:workoutId',
        builder: (context, state) {
          final workoutId = state.pathParameters['workoutId']!;
          return EditWorkoutScreen(workoutId: workoutId);
        },
      ),
      GoRoute(
        path: '/workout-detail/:workoutId',
        builder: (context, state) {
          final workoutId = state.pathParameters['workoutId']!;
          return WorkoutDetailScreen(workoutId: workoutId);
        },
      ),
      GoRoute(
        path: '/exercise-detail/:exerciseId',
        builder: (context, state) {
          final exerciseId = state.pathParameters['exerciseId']!;
          return ExerciseDetailScreen(exerciseId: exerciseId);
        },
      ),
      GoRoute(
        path: '/exercise/:exerciseName',
        builder: (context, state) {
          final exerciseName = state.pathParameters['exerciseName']!;
          return ExerciseDetailScreen(
            exerciseName: exerciseName,
            workoutName: 'Peito', // Exemplo
          );
        },
      ),
    ],
  );
});
