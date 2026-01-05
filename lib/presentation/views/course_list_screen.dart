import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/enrollment_viewmodel.dart';
import '../widgets/course_card.dart';

/// Course list screen for browsing and enrolling
class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleEnroll(String courseId) async {
    final enrollmentViewModel = context.read<EnrollmentViewModel>();
    final success = await enrollmentViewModel.enrollInCourse(courseId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Successfully enrolled!'
                : enrollmentViewModel.errorMessage ?? 'Failed to enroll',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDrop(String courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drop Course'),
        content: const Text(
          'Are you sure you want to drop this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Drop'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final enrollmentViewModel = context.read<EnrollmentViewModel>();
    final success = await enrollmentViewModel.dropCourse(courseId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Course dropped successfully'
                : enrollmentViewModel.errorMessage ?? 'Failed to drop course',
          ),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Courses'),
            Tab(text: 'My Enrollments'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Course lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Courses Tab
                Consumer<EnrollmentViewModel>(
                  builder: (context, enrollment, _) {
                    if (enrollment.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var courses = enrollment.courses;
                    if (_searchQuery.isNotEmpty) {
                      courses = courses.where((c) {
                        final query = _searchQuery.toLowerCase();
                        return c.name.toLowerCase().contains(query) ||
                            c.code.toLowerCase().contains(query) ||
                            (c.description?.toLowerCase().contains(query) ??
                                false);
                      }).toList();
                    }

                    if (courses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No courses found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final userId = context.read<AuthViewModel>().userId;
                        if (userId != null) {
                          await enrollment.loadAll(userId);
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final isEnrolled = enrollment.isEnrolledIn(course.id);
                          final isProcessing =
                              enrollment.state == EnrollmentState.enrolling ||
                              enrollment.state == EnrollmentState.dropping;

                          return CourseCard(
                            course: course,
                            isEnrolled: isEnrolled,
                            isLoading: isProcessing,
                            onEnroll: () => _handleEnroll(course.id),
                            onDrop: () => _handleDrop(course.id),
                          );
                        },
                      ),
                    );
                  },
                ),

                // My Enrollments Tab
                Consumer<EnrollmentViewModel>(
                  builder: (context, enrollment, _) {
                    if (enrollment.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var enrolledCourses = enrollment.courses
                        .where((c) => enrollment.isEnrolledIn(c.id))
                        .toList();

                    if (_searchQuery.isNotEmpty) {
                      enrolledCourses = enrolledCourses.where((c) {
                        final query = _searchQuery.toLowerCase();
                        return c.name.toLowerCase().contains(query) ||
                            c.code.toLowerCase().contains(query);
                      }).toList();
                    }

                    if (enrolledCourses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_add_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No enrolled courses',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Browse courses to enroll',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final userId = context.read<AuthViewModel>().userId;
                        if (userId != null) {
                          await enrollment.loadEnrollments(userId);
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: enrolledCourses.length,
                        itemBuilder: (context, index) {
                          final course = enrolledCourses[index];
                          final isProcessing =
                              enrollment.state == EnrollmentState.dropping;

                          return CourseCard(
                            course: course,
                            isEnrolled: true,
                            isLoading: isProcessing,
                            onDrop: () => _handleDrop(course.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
