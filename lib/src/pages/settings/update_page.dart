part of pages;

class UpdatePage extends StatefulWidget {
  final String title;

  const UpdatePage({
    super.key,
    required this.title,
  });

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCustomAppBar(
        title: Text(
          widget.title.translate(),
        ),
      ),
    );
  }
}
