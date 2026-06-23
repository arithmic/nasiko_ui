import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nasiko_ui/nasiko_ui.dart';
import 'package:nasiko_ui_example/text_box_example.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final Map<NasikoSwitchSize, bool> _switches = {
    NasikoSwitchSize.large: true,
    NasikoSwitchSize.small: true,
  };
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1512, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Nasiko UI Design System',
          theme: NasikoTheme.lightTheme,
          darkTheme: NasikoTheme.darkTheme,
          themeMode: _themeMode,
          home: ExampleHomePage(
            onThemeToggle: () {
              setState(() {
                _themeMode = _themeMode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
              });
            },
            switches: _switches,
            onSwitchToggled: (size, value) {
              setState(() {
                _switches[size] = value;
              });
            },
          ),
        );
      },
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final Map<NasikoSwitchSize, bool> switches;
  final void Function(NasikoSwitchSize size, bool value) onSwitchToggled;

  const ExampleHomePage({
    required this.onThemeToggle,
    required this.switches,
    required this.onSwitchToggled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nasiko Design System',
          style: context.typography.titlePrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'Colors',
              child: _buildColorGrid(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Typography',
              child: _buildTypographyExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Spacing',
              child: _buildSpacingExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Border Radius',
              child: _buildBorderRadiusExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Icon Sizes',
              child: _buildIconSizesExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Border Widths',
              child: _buildBorderWidthExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'NasikoButton (V2 — Type × Tone × Size)',
              child: _buildNasikoButtonExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'NasikoIconButton (V2 — Type × Tone × Size)',
              child: _buildNasikoIconButtonExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Cards',
              child: _buildCardsExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Input Fields',
              child: _buildInputFieldsExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'NasikoInput (V2 — State × Size)',
              child: const _NasikoInputExample(),
            ),
            _buildSection(
              context,
              title: 'NasikoSearch (V2 — State × Size)',
              child: const _NasikoSearchExample(),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(context, title: 'Menu', child: const _MenuExample()),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Tab Bar',
              child: const _TabBarExample(),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Accordion',
              child: _buildAccordionExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Avatars',
              child: _buildAvatarsExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Banners',
              child: _buildBannersExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Breadcrumbs',
              child: _buildBreadcrumbsExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Checkboxes',
              child: const _CheckboxExample(),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Radio',
              child: const _RadioExample(),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(context, title: 'Chips', child: const _ChipExample()),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Dividers',
              child: _buildDividersExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Lists & Hierarchy',
              child: const _ListExample(),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Modals',
              child: _buildModalsExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Table',
              child: _buildTableExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Toast Notifications',
              child: _buildToastExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Switch',
              child: _buildSwitchExample(context),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Navigation Sections',
              child: const _SectionExample(),
            ),
            SizedBox(height: context.spacing.s28),
            _buildSection(
              context,
              title: 'Query Box',
              child: _buildQueryBoxExample(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.typography.titleSecondary.copyWith(
            color: context.colors.foregroundPrimary,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        child,
      ],
    );
  }

  Widget _buildColorGrid(BuildContext context) {
    return Wrap(
      spacing: context.spacing.s8,
      runSpacing: context.spacing.s8,
      children: [
        _buildColorTile(
          context,
          label: 'Brand',
          color: context.colors.backgroundBrand,
          textColor: context.colors.foregroundPrimary,
        ),
        _buildColorTile(
          context,
          label: 'Success',
          color: context.colors.backgroundSuccess,
          textColor: context.colors.foregroundPrimary,
        ),
        _buildColorTile(
          context,
          label: 'Error',
          color: context.colors.backgroundError,
          textColor: context.colors.foregroundPrimary,
        ),
        _buildColorTile(
          context,
          label: 'Warning',
          color: context.colors.backgroundWarning,
          textColor: context.colors.foregroundPrimary,
        ),
      ],
    );
  }

  Widget _buildColorTile(
    BuildContext context, {
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.radius.r8),
        border: Border.all(
          color: context.colors.borderPrimary,
          width: context.borderWidth.w1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: context.typography.bodyPrimary.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypographyExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title Primary', style: context.typography.titlePrimary),
        SizedBox(height: context.spacing.s8),
        Text('Title Secondary', style: context.typography.titleSecondary),
        SizedBox(height: context.spacing.s8),
        Text('Body Primary', style: context.typography.bodyPrimary),
        SizedBox(height: context.spacing.s8),
        Text(
          'Body Secondary',
          style: context.typography.bodySecondary.copyWith(
            color: context.colors.foregroundSecondary,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        Text(
          'Caption',
          style: context.typography.caption.copyWith(
            color: context.colors.foregroundSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpacingBar(context, 's0', context.spacing.s0),
        _buildSpacingBar(context, 's4', context.spacing.s4),
        _buildSpacingBar(context, 's8', context.spacing.s8),
        _buildSpacingBar(context, 's16', context.spacing.s16),
        _buildSpacingBar(context, 's24', context.spacing.s24),
        _buildSpacingBar(context, 's36', context.spacing.s36),
        _buildSpacingBar(context, 's48', context.spacing.s48),
      ],
    );
  }

  Widget _buildSpacingBar(BuildContext context, String label, double size) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.s8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: context.typography.bodyPrimary),
          ),
          Container(
            width: size,
            height: 20,
            decoration: BoxDecoration(
              color: context.colors.backgroundBrand,
              borderRadius: BorderRadius.circular(context.radius.r4),
            ),
          ),
          SizedBox(width: context.spacing.s8),
          Text(
            '${size.toInt()}px',
            style: context.typography.bodySecondary.copyWith(
              color: context.colors.foregroundSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorderRadiusExample(BuildContext context) {
    return Wrap(
      spacing: context.spacing.s8,
      runSpacing: context.spacing.s8,
      children: [
        _buildRadiusTile(context, 'r4', context.radius.r4),
        _buildRadiusTile(context, 'r8', context.radius.r8),
        _buildRadiusTile(context, 'r12', context.radius.r12),
        _buildRadiusTile(context, 'r16', context.radius.r16),
      ],
    );
  }

  Widget _buildRadiusTile(BuildContext context, String label, double radius) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colors.backgroundBrand,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        SizedBox(height: context.spacing.s8),
        Text(label, style: context.typography.bodyPrimary),
      ],
    );
  }

  Widget _buildIconSizesExample(BuildContext context) {
    return Wrap(
      spacing: context.spacing.s16,
      runSpacing: context.spacing.s16,
      children: [
        _buildIconSizeTile(context, 'xs', context.iconSize.xs),
        _buildIconSizeTile(context, 'sm', context.iconSize.sm),
        _buildIconSizeTile(context, 'md', context.iconSize.md),
        _buildIconSizeTile(context, 'lg', context.iconSize.lg),
        _buildIconSizeTile(context, 'xl', context.iconSize.xl),
      ],
    );
  }

  Widget _buildIconSizeTile(BuildContext context, String label, double size) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.colors.backgroundBrand,
            borderRadius: BorderRadius.circular(context.radius.r4),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.star,
            size: size * 0.7,
            color: context.colors.foregroundPrimary,
          ),
        ),
        SizedBox(height: context.spacing.s4),
        Text(label, style: context.typography.caption),
      ],
    );
  }

  Widget _buildBorderWidthExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBorderWidthTile(context, 'w0', context.borderWidth.w0),
        _buildBorderWidthTile(context, 'w1', context.borderWidth.w1),
        _buildBorderWidthTile(context, 'w2', context.borderWidth.w2),
        _buildBorderWidthTile(context, 'w4', context.borderWidth.w4),
        _buildBorderWidthTile(context, 'w8', context.borderWidth.w8),
      ],
    );
  }

  Widget _buildBorderWidthTile(
    BuildContext context,
    String label,
    double width,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.s12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: context.typography.caption),
          ),
          Container(
            width: 150,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colors.borderPrimary,
                width: width,
              ),
              borderRadius: BorderRadius.circular(context.radius.r4),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildNasikoButtonExample(BuildContext context) {
    Widget rowForSize(NasikoButtonSize size, String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.typography.bodyPrimaryBold),
          SizedBox(height: context.spacing.s12),
          Wrap(
            spacing: context.spacing.s12,
            runSpacing: context.spacing.s12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // One of each type (default tone).
              for (final type in NasikoButtonType.values)
                NasikoButton(
                  type: type,
                  size: size,
                  label: type.name,
                  onPressed: () {},
                  leadingIcon: HugeIcons.strokeRoundedAdd01,
                  trailingIcon: HugeIcons.strokeRoundedArrowRight01,
                ),
              // Destructive tone (only primary + secondary).
              NasikoButton(
                type: NasikoButtonType.primary,
                tone: NasikoButtonTone.destructive,
                size: size,
                label: 'delete',
                onPressed: () {},
                leadingIcon: HugeIcons.strokeRoundedDelete02,
              ),
              NasikoButton(
                type: NasikoButtonType.secondary,
                tone: NasikoButtonTone.destructive,
                size: size,
                label: 'delete',
                onPressed: () {},
                leadingIcon: HugeIcons.strokeRoundedDelete02,
              ),
              // Disabled.
              NasikoButton(
                type: NasikoButtonType.primary,
                size: size,
                label: 'disabled',
                onPressed: null,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowForSize(NasikoButtonSize.large, 'Large'),
        SizedBox(height: context.spacing.s20),
        rowForSize(NasikoButtonSize.medium, 'Medium'),
        SizedBox(height: context.spacing.s20),
        rowForSize(NasikoButtonSize.small, 'Small'),
      ],
    );
  }

  Widget _buildNasikoIconButtonExample(BuildContext context) {
    Widget rowForSize(NasikoButtonSize size, String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.typography.bodyPrimaryBold),
          SizedBox(height: context.spacing.s12),
          Wrap(
            spacing: context.spacing.s12,
            runSpacing: context.spacing.s12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final type in NasikoButtonType.values)
                NasikoIconButton(
                  type: type,
                  size: size,
                  icon: HugeIcons.strokeRoundedAdd01,
                  onPressed: () {},
                ),
              NasikoIconButton(
                type: NasikoButtonType.primary,
                tone: NasikoButtonTone.destructive,
                size: size,
                icon: HugeIcons.strokeRoundedDelete02,
                onPressed: () {},
              ),
              NasikoIconButton(
                type: NasikoButtonType.secondary,
                tone: NasikoButtonTone.destructive,
                size: size,
                icon: HugeIcons.strokeRoundedDelete02,
                onPressed: () {},
              ),
              NasikoIconButton(
                type: NasikoButtonType.primary,
                size: size,
                icon: HugeIcons.strokeRoundedAdd01,
                onPressed: null,
              ),
              NasikoIconButton(
                type: NasikoButtonType.primary,
                size: size,
                icon: HugeIcons.strokeRoundedAdd01,
                onPressed: () {},
                isLoading: true,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowForSize(NasikoButtonSize.large, 'Large'),
        SizedBox(height: context.spacing.s20),
        rowForSize(NasikoButtonSize.medium, 'Medium'),
        SizedBox(height: context.spacing.s20),
        rowForSize(NasikoButtonSize.small, 'Small'),
      ],
    );
  }

  Widget _buildCardsExample(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: NasikoCard(
            title: 'Document Expert',
            tags: [
              'document analysis',
              'chat',
              'history',
              'document analysis',
              'chat',
              'history',
              'document analysis',
              'chat',
              'history',
            ],
            description: 'A helpful assistant that answers user questions.',
          ),
        ),
        SizedBox(width: context.spacing.s16),
        Expanded(
          child: NasikoAgentCard(
            title: 'Document Expert',
            tags: [
              'document analysis',
              'chat',
              'history',
              'document analysis',
              'chat',
              'history',
              'document analysis',
              'chat',
              'history',
            ],
            description:
                'A helpful assistant that answers user questions based on the provided document. It supports file uploads for document processing and maintains a chat history for each session.',
            onTap: () {},
            menuActions: [
              NasikoPopupMenuItemData(
                label: 'Edit',
                icon: HugeIcons.strokeRoundedEdit01,
              ),
              NasikoPopupMenuItemData(
                label: 'Delete',
                icon: HugeIcons.strokeRoundedDelete02,
              ),
            ],
          ),
        ),
        SizedBox(width: context.spacing.s16),
        Expanded(
          child: NasikoCard(
            title: 'Code Expert',
            tags: ['code analysis', 'chat', 'history'],
            description:
                'An AI-powered coding assistant that helps users understand and debug code snippets. It supports multiple programming languages and maintains a chat history for each session.',
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NasikoInput(
          label: 'Label',
          placeholder: 'Email',
          showHint: true,
          hint: 'Hint',
          leadingIcon: HugeIcons.strokeRoundedMail01,
          trailingIcon: HugeIcons.strokeRoundedInformationCircle,
          onChanged: (value) {
            // Handle change
          },
          required: true,
        ),
        SizedBox(height: context.spacing.s16),
        NasikoInput(
          label: 'Password',
          placeholder: 'Enter your password',
          showHint: true,
          hint: 'Must be 8 characters.',
          leadingIcon: HugeIcons.strokeRoundedLock,
          obscureText: true,
          showPasswordToggle: true,
          onChanged: (value) {
            // Handle change
          },
          required: true,
        ),
      ],
    );
  }

  Widget _buildAccordionExample(BuildContext context) {
    final items = [
      NasikoAccordionItem(
        title: 'Add Agent',
        content: Text(
          'We think solving this problem is profoundly impactful, '
          'considering the gains that can be unlocked across all levels of '
          'the AI stack once kernels are no longer a bottleneck.',
        ),
      ),
      NasikoAccordionItem(
        title: 'Add Agent 2',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This is the content for the second item.'),
            SizedBox(height: context.spacing.s16),
            NasikoButton(
              type: NasikoButtonType.primary,
              onPressed: () {},
              label: 'Nested Button',
              size: NasikoButtonSize.small,
            ),
          ],
        ),
      ),
      NasikoAccordionItem(
        title: 'Add Agent 3',
        content: const Text('This is the content for the third item.'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'One Item Open (Default)',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        NasikoAccordion(
          items: items,
          initialOpenIndex: 0, // Start with the first item open
        ),
        SizedBox(height: context.spacing.s24),
        Text(
          'Multiple Items Open',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        NasikoAccordion(
          items: items,
          allowMultipleOpen: true,
          initialOpenIndices: const {0}, // Start with the first item open
        ),
      ],
    );
  }

  Widget _buildAvatarsExample(BuildContext context) {
    // A placeholder image URL
    const String imageUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4JCuHyuURcCyeNEc9v4iOma3HVgZgDSMaIQ&s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Large ---
        Wrap(
          spacing: context.spacing.s16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            NasikoAvatar(
              size: NasikoAvatarSize.large,
              icon: HugeIcons.strokeRoundedRelieved01,
            ),
            NasikoAvatar(size: NasikoAvatarSize.large, imageUrl: imageUrl),
            NasikoAvatar(size: NasikoAvatarSize.large, text: 'AJ'),
          ],
        ),
        SizedBox(height: context.spacing.s16),
        // --- Medium ---
        Wrap(
          spacing: context.spacing.s16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            NasikoAvatar(
              size: NasikoAvatarSize.medium,
              icon: HugeIcons.strokeRoundedRelieved01,
            ),
            NasikoAvatar(size: NasikoAvatarSize.medium, imageUrl: imageUrl),
            NasikoAvatar(size: NasikoAvatarSize.medium, text: 'AJ'),
          ],
        ),
        SizedBox(height: context.spacing.s16),
        // --- Small ---
        Wrap(
          spacing: context.spacing.s16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            NasikoAvatar(
              size: NasikoAvatarSize.small,
              icon: HugeIcons.strokeRoundedRelieved01,
            ),
            NasikoAvatar(size: NasikoAvatarSize.small, imageUrl: imageUrl),
            NasikoAvatar(size: NasikoAvatarSize.small, text: 'AJ'),
          ],
        ),
      ],
    );
  }

  Widget _buildBannersExample(BuildContext context) {
    const bannerImage = AssetImage(
      'assets/images/avatar.png',
      package: 'nasiko_ui',
    );

    const content =
        'Register your own AI agent with metadata, schema, and policies.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Horizontal Banner ---
        NasikoBanner(
          title: 'Add Agent',
          bannerIconImage: bannerImage,
          content: content,
          onClose: () {
            debugPrint('Horizontal Banner closed');
          },
          action: NasikoButton(
            type: NasikoButtonType.primary,
            onPressed: () {},
            label: 'Add Agent',
            size: NasikoButtonSize.small,
            trailingIcon: HugeIcons.strokeRoundedInformationCircle,
          ),
        ),

        SizedBox(height: context.spacing.s16),

        // --- Vertical Banner ---
        NasikoBanner(
          title: 'Add Agent',
          bannerIconImage: bannerImage,
          content: content,
          bannerType: NasikoBannerType.vertical,
          onClose: () {
            debugPrint('Vertical Banner closed');
          },
          action: NasikoButton(
            type: NasikoButtonType.primary,
            onPressed: () {},
            label: 'Button',
            size: NasikoButtonSize.small,
            leadingIcon: HugeIcons.strokeRoundedInformationSquare,
            trailingIcon: HugeIcons.strokeRoundedInformationCircle,
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbsExample(BuildContext context) {
    final items = [
      NasikoBreadcrumbItem(
        label: 'Button',
        onTap: () {
          debugPrint('Tapped Breadcrumb 1');
        },
      ),
      NasikoBreadcrumbItem(
        label: 'Button',
        onTap: () {
          debugPrint('Tapped Breadcrumb 2');
        },
      ),
      NasikoBreadcrumbItem(
        label: 'Button',
        onTap: () {
          debugPrint('Tapped Breadcrumb 3');
        },
      ),
      NasikoBreadcrumbItem(
        label: 'Button',
        onTap: () {
          debugPrint('Tapped Breadcrumb 4');
        },
      ),
      NasikoBreadcrumbItem(label: 'Button'),
    ];

    return NasikoBreadcrumb(
      leadingIcon: Icons.folder_open_outlined,
      items: items,
    );
  }

  Widget _buildDividersExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horizontal',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Text('Content above', style: context.typography.bodySecondary),
        SizedBox(height: context.spacing.s12),
        const NasikoDivider(axis: NasikoDividerAxis.horizontal),
        SizedBox(height: context.spacing.s12),
        Text('Content below', style: context.typography.bodySecondary),
        SizedBox(height: context.spacing.s24),
        Text(
          'Vertical',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              Text('Content left', style: context.typography.bodySecondary),
              SizedBox(width: context.spacing.s12),
              const NasikoDivider(axis: NasikoDividerAxis.vertical),
              SizedBox(width: context.spacing.s12),
              Text('Content right', style: context.typography.bodySecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalsExample(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        NasikoButton(
          type: NasikoButtonType.primary,
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Save changes',
              content: const Text('Do you want to save your changes?'),
              primaryButtonLabel: 'Save',
              secondaryButtonLabel: 'Cancel',
              backgroundColor: context.colors.backgroundSurface,
            );
          },
          label: 'Primary action modal',
        ),
        SizedBox(width: context.spacing.s16),
        NasikoButton(
          type: NasikoButtonType.primary,
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Delete workspace',
              titleType: NasikoModalTitleType.error,
              titleIcon: HugeIcons.strokeRoundedUserWarning01,
              content: const Text(
                'This action is permanent and cannot be undone.',
              ),
              primaryButtonLabel: 'Delete',
              primaryButtonIntent: NasikoModalButtonIntent.destructive,
              secondaryButtonLabel: 'Cancel',
            );
          },
          label: 'Primary destructive button modal',
        ),
        SizedBox(width: context.spacing.s16),
        NasikoButton(
          type: NasikoButtonType.primary,
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Remove member',
              content: const Text('The member will lose access immediately.'),
              primaryButtonLabel: 'Remove',
              secondaryButtonLabel: 'Remove anyway',
              secondaryButtonHierarchy: NasikoModalButtonHierarchy.secondary,
              secondaryButtonIntent: NasikoModalButtonIntent.destructive,
            );
          },
          label: 'Secondary destructive button modal',
        ),
        SizedBox(width: context.spacing.s16),
        NasikoButton(
          type: NasikoButtonType.primary,
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Clear history',
              content: const Text('This will clear all local history.'),
              secondaryButtonLabel: 'Clear history',
              secondaryButtonHierarchy: NasikoModalButtonHierarchy.tertiary,
              secondaryButtonIntent: NasikoModalButtonIntent.destructive,
            );
          },
          label: 'Tertiary destructive button modal',
        ),
        SizedBox(width: context.spacing.s16),
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show Confirmation',
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Add Agent',
              titleIcon: HugeIcons.strokeRoundedAdd01,
              content: Text(
                'Register your own AI agent with metadata, schema, and policies.',
                style: context.typography.bodySecondary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
              primaryButtonLabel: 'Confirm',
              secondaryButtonLabel: 'Delete',
              onPrimaryAction: () {
                Navigator.of(context).pop();
                // Perform the confirmation action here
              },
            );
          },
        ),
        SizedBox(width: context.spacing.s16),

        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show Alert',
          onPressed: () {
            showNasikoModal(
              context: context,
              buttonLayout: NasikoModalVariant.vertical,
              title: 'Action Failed',
              titleIcon: HugeIcons.strokeRoundedSpam,
              content: Text(
                'The requested operation failed due to a server error. Please try again later.',
                style: context.typography.bodySecondary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
              primaryButtonLabel: 'Dismiss',
              secondaryButtonLabel: 'Delete',
              secondaryButtonIsDanger: true,
              onPrimaryAction: () => Navigator.of(context).pop(),
              // Only one button for a simple alert
            );
          },
        ),
      ],
    );
  }

  // Helper widget to simulate the 'Active' status pill in the design
  // Widget _buildStatusPill(
  //   BuildContext context, {
  //   required String label,
  //   required Color color,
  // }) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: context.spacing.s8,
  //       vertical: context.spacing.s4,
  //     ),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.15), // Light background tint
  //       borderRadius: BorderRadius.circular(
  //         context.radius.r40,
  //       ), // Fully rounded
  //       border: Border.all(color: color, width: context.borderWidth.w1),
  //     ),
  //     child: Text(
  //       label,
  //       style: context.typography.caption.copyWith(
  //         color: color,
  //         fontWeight: FontWeight.w600,
  //         fontStyle:
  //             FontStyle.normal, // Override the default italic caption style
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTableExample(BuildContext context) {
    // Define columns matching the design
    final columns = [
      const NasikoTableColumn(title: '.Cell Item', flex: 3),
      const NasikoTableColumn(
        title: '.Cell',
        flex: 2,
        alignment: Alignment.center,
      ),
      const NasikoTableColumn(
        title: '.Column',
        flex: 2,
        alignment: Alignment.centerRight,
      ),
    ];

    // Create rows with different cell content types
    final data = [
      // Row 1: Copy cells
      [
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 2: Copy cells
      [
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 3: Complex cell with button
      [
        const NasikoTableCellItem(showButton: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 4: Complex cell with icons
      [
        const NasikoTableCellItem(showIcons: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 5: Complex cell with tags
      [
        const NasikoTableCellItem(showTags: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 6: Complex cell with checkbox
      [
        const NasikoTableCellItem(showCheckbox: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 7: Complex cell with radio
      [
        const NasikoTableCellItem(showRadio: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 8: Complex cell with avatar
      [
        const NasikoTableCellItem(showAvatar: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 9: Complex cell with switch
      [
        const NasikoTableCellItem(showSwitch: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Row 10: Complex cell with status
      [
        const NasikoTableCellItem(showStatus: true),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],

      // Add more rows as needed
      [
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
        const NasikoTableCopyCell(),
      ],
    ];

    return NasikoTable(
      columns: columns,
      data: data,
      bodyHeight: 500, // Adjust as needed
    );
  }

  Widget _buildToastExample(BuildContext context) {
    final spacing = context.spacing;
    return Wrap(
      spacing: spacing.s16,
      runSpacing: spacing.s16,
      children: [
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show Success Toast',
          onPressed: () => NasikoToastService.showSuccess(
            context,
            'Operation successful! Your settings have been saved and applied.',
          ),
        ),
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show Error Toast',
          onPressed: () => NasikoToastService.showError(
            context,
            'Failed to load resource. Check your network connection.',
          ),
        ),
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show Warning Toast',
          onPressed: () => NasikoToastService.show(
            context,
            message: 'Data migration in progress. Do not refresh this page.',
            type: NasikoToastType.warning,
          ),
        ),
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show Info Toast',
          onPressed: () => NasikoToastService.show(
            context,
            message: 'The new feature roadmap is now available for review.',
            type: NasikoToastType.info,
          ),
        ),
        NasikoButton(
          type: NasikoButtonType.primary,
          label: 'Show In progress Info Toast',
          onPressed: () => NasikoToastService.show(
            context,
            message: 'The new feature roadmap is now available for review.',
            type: NasikoToastType.info,
            inProgress: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchExample(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Large', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        // Row 1: Active/Inactive Switch
        Text('Interactive Switch', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        Row(
          children: [
            // This uses the 'isSwitchActive' state passed from the parent StatefulWidget
            NasikoSwitch(
              value: switches[NasikoSwitchSize.large]!,
              size: NasikoSwitchSize.large,
              // This calls the 'onSwitchToggled' function, which executes setState in the parent
              onChanged: (value) =>
                  onSwitchToggled(NasikoSwitchSize.large, value),
            ),
            SizedBox(width: spacing.s16),
            Text(
              switches[NasikoSwitchSize.large]!
                  ? 'ON (Active)'
                  : 'OFF (Inactive)',
              style: typography.bodyPrimary.copyWith(
                color: switches[NasikoSwitchSize.large]!
                    ? colors.foregroundBrand
                    : colors.foregroundSecondary,
              ),
            ),
          ],
        ),

        // --- Separator ---
        SizedBox(height: spacing.s24),

        // Row 2: Disabled Switch
        Text('Disabled Switch (Value OFF)', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        // Disabled Switch (The 'onChanged' property is null)
        NasikoSwitch(
          value: false,
          size: NasikoSwitchSize.large,
          onChanged: null,
        ),

        // --- Separator ---
        SizedBox(height: spacing.s24),

        // Row 3: Disabled Switch
        Text('Disabled Switch (Value ON)', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        // Disabled Switch (Value is ON, onChanged is null)
        NasikoSwitch(
          value: true,
          size: NasikoSwitchSize.large,
          onChanged: null,
        ),

        SizedBox(height: context.spacing.s24),

        Text('Small', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        // Row 1: Active/Inactive Switch
        Text('Interactive Switch', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        Row(
          children: [
            // This uses the 'isSwitchActive' state passed from the parent StatefulWidget
            NasikoSwitch(
              value: switches[NasikoSwitchSize.small]!,
              size: NasikoSwitchSize.small,
              // This calls the 'onSwitchToggled' function, which executes setState in the parent
              onChanged: (value) =>
                  onSwitchToggled(NasikoSwitchSize.small, value),
            ),
            SizedBox(width: spacing.s16),
            Text(
              switches[NasikoSwitchSize.small]!
                  ? 'ON (Active)'
                  : 'OFF (Inactive)',
              style: typography.bodyPrimary.copyWith(
                color: switches[NasikoSwitchSize.small]!
                    ? colors.foregroundBrand
                    : colors.foregroundSecondary,
              ),
            ),
          ],
        ),

        // --- Separator ---
        SizedBox(height: spacing.s24),

        // Row 2: Disabled Switch
        Text('Disabled Switch (Value OFF)', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        // Disabled Switch (The 'onChanged' property is null)
        NasikoSwitch(
          value: false,
          size: NasikoSwitchSize.small,
          onChanged: null,
        ),

        // --- Separator ---
        SizedBox(height: spacing.s24),

        // Row 3: Disabled Switch
        Text('Disabled Switch (Value ON)', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        // Disabled Switch (Value is ON, onChanged is null)
        NasikoSwitch(
          value: true,
          size: NasikoSwitchSize.small,
          onChanged: null,
        ),
      ],
    );
  }

  Widget _buildQueryBoxExample(BuildContext context) {
    return const TextBoxExample();
  }
}

class _TabBarExample extends StatefulWidget {
  const _TabBarExample();

  @override
  State<_TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<_TabBarExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    final List<NasikoTabItem> tabs = [
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
      const NasikoTabItem(
        label: 'Trace',
        icon: HugeIcon(icon: HugeIcons.strokeRoundedNeuralNetwork),
      ),
    ];

    return Column(
      children: [
        NasikoTabBar(controller: _tabController, tabs: tabs),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: tabs.map((item) {
              return Center(
                child: Text(
                  '${item.label} ${tabs.indexOf(item)} Content',
                  style: context.typography.bodyPrimary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _MenuExample extends StatefulWidget {
  const _MenuExample();

  @override
  State<_MenuExample> createState() => _MenuExampleState();
}

class _MenuExampleState extends State<_MenuExample> {
  // This list can be as long as you want
  final List<NasikoPopupMenuItemData> _menuItems = [
    NasikoPopupMenuItemData(
      label: 'Label 1',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 2',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 3',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 4',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 5',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 6',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 7',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
    NasikoPopupMenuItemData(
      label: 'Label 8',
      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NasikoPopupMenu(
      items: _menuItems,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: NasikoButton(
        type: NasikoButtonType.secondary,
        label: _menuItems[_selectedIndex].label,
        size: NasikoButtonSize.medium,
        trailingIcon: HugeIcons.strokeRoundedArrowDown01,
        onPressed: () {},
      ),
    );
  }
}

class _CheckboxExample extends StatefulWidget {
  const _CheckboxExample();

  @override
  State<_CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<_CheckboxExample> {
  bool _isChecked1 = true;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Labeled Row Example ---
        Text(
          'Checkbox Row (like CheckboxListTile)',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        NasikoCheckboxTile(
          label: 'Airplane Mode',
          icon: Icons.airplanemode_active,
          isChecked: _isChecked1,
          onChanged: (value) => setState(() => _isChecked1 = value!),
        ),
        NasikoCheckboxTile(
          label: 'Disabled Item',
          icon: Icons.do_not_disturb,
          isChecked: false,
          onChanged: null, // Disables the row
        ),

        SizedBox(height: context.spacing.s24),

        // --- Raw Checkbox Example ---
        Text(
          'Raw Checkbox (Just the box)',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s16,
          children: [
            NasikoCheckbox(
              isChecked: _isChecked2,
              onChanged: (value) => setState(() => _isChecked2 = value!),
            ),
            NasikoCheckbox(
              isChecked: _isChecked3,
              onChanged: (value) => setState(() => _isChecked3 = value!),
            ),
            NasikoCheckbox(
              isChecked: _isChecked4,
              onChanged: (value) => setState(() => _isChecked4 = value!),
            ),
            NasikoCheckbox(
              isChecked: true,
              onChanged: null, // Disabled (checked)
            ),
            NasikoCheckbox(
              isChecked: false,
              onChanged: null, // Disabled (unchecked)
            ),
          ],
        ),
      ],
    );
  }
}

class _RadioExample extends StatefulWidget {
  const _RadioExample();

  @override
  State<_RadioExample> createState() => _RadioExampleState();
}

class _RadioExampleState extends State<_RadioExample> {
  String? _selectedOption = 'option1';
  final String _disabledOption = 'disabled1';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default State',
          style: context.typography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        Row(
          children: [
            NasikoRadioTile<String>(
              label: 'Option 1',
              value: 'option1',
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value),
            ),
            SizedBox(width: context.spacing.s8),
            SizedBox(width: context.spacing.s24),
            NasikoRadioTile<String>(
              label: 'Option 2',
              value: 'option2',
              icon: HugeIcons.strokeRoundedAirplaneMode,
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value),
            ),
            SizedBox(width: context.spacing.s8),
            SizedBox(width: context.spacing.s24),
            NasikoRadioTile<String>(
              label: 'Option 3',
              value: 'option3',
              groupValue: _selectedOption,
              onChanged: (value) => setState(() => _selectedOption = value),
            ),
            SizedBox(width: context.spacing.s8),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        Text(
          'Disabled State',
          style: context.typography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        Row(
          children: [
            NasikoRadioTile<String>(
              label: 'Disabled Selected',
              value: 'disabled1',
              groupValue: _disabledOption,
              onChanged: null, // Disabled
            ),
            SizedBox(width: context.spacing.s8),
            SizedBox(width: context.spacing.s24),
            NasikoRadioTile<String>(
              label: 'Disabled Unselected',
              value: 'disabled2',
              groupValue: _disabledOption,
              onChanged: null, // Disabled
            ),
            SizedBox(width: context.spacing.s8),
          ],
        ),
      ],
    );
  }
}

class _ListExample extends StatefulWidget {
  const _ListExample();

  @override
  State<_ListExample> createState() => _ListExampleState();
}

class _ListExampleState extends State<_ListExample> {
  // Simulate some state
  bool _isRootExpanded = true;
  bool _isChildExpanded = true;
  int _selectedId = 2; // ID of the selected item

  @override
  Widget build(BuildContext context) {
    // A placeholder image URL
    const String imageUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS4JCuHyuURcCyeNEc9v4iOma3HVgZgDSMaIQ&s';

    return NasikoList(
      children: [
        // --- Item 1: Root (Expanded) ---
        NasikoListItem(
          title: 'POST/ chat',
          imageUrl: imageUrl,
          leadingIcon: HugeIcons.strokeRoundedChatBot,
          badgeLabel: '1.85s',
          badgeIcon: HugeIcons.strokeRoundedTime03,
          showStatusDot: true,
          indentLevel: 0,
          hasChildren: true,
          isExpanded: _isRootExpanded,
          // Toggle logic
          onToggleExpand: () =>
              setState(() => _isRootExpanded = !_isRootExpanded),
          onTap: () => setState(() => _selectedId = 1),
          isSelected: _selectedId == 1,
        ),

        // --- Item 2: Child (Selected) ---
        if (_isRootExpanded)
          NasikoListItem(
            title: 'POST/ chat (Selected)',
            imageUrl: imageUrl,
            leadingIcon: HugeIcons.strokeRoundedChatBot,
            badgeLabel: '1.85s',
            badgeIcon: HugeIcons.strokeRoundedTime03,
            showStatusDot: true,
            indentLevel: 1, // Indented
            hasChildren: true,
            isExpanded: _isChildExpanded,
            onToggleExpand: () =>
                setState(() => _isChildExpanded = !_isChildExpanded),
            onTap: () => setState(() => _selectedId = 2),
            isSelected: _selectedId == 2, // Matches simulated ID
          ),

        // --- Item 3: Grandchild (Hover/Default) ---
        if (_isRootExpanded && _isChildExpanded)
          NasikoListItem(
            title: 'POST/ chat',
            imageUrl: imageUrl,
            leadingIcon: HugeIcons.strokeRoundedChatBot,
            badgeLabel: '1.85s',
            badgeIcon: HugeIcons.strokeRoundedTime03,
            showStatusDot: true,
            indentLevel: 2, // Double Indented
            hasChildren: false,
            onTap: () => setState(() => _selectedId = 3),
            isSelected: _selectedId == 3,
          ),

        // --- Item 4: Disabled ---
        if (_isRootExpanded && _isChildExpanded)
          NasikoListItem(
            title: 'POST/ chat (Disabled)',
            imageUrl: imageUrl,
            leadingIcon: HugeIcons.strokeRoundedChatBot,
            badgeLabel: '1.85s',
            badgeIcon: HugeIcons.strokeRoundedTime03,
            indentLevel: 2,
            isDisabled: true, // Disabled state
          ),
      ],
    );
  }
}

class _SectionExample extends StatefulWidget {
  const _SectionExample();

  @override
  State<_SectionExample> createState() => _SectionExampleState();
}

class _SectionExampleState extends State<_SectionExample> {
  String _selectedSection = 'Orchestrator';
  String? _selectedChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.s16),
      decoration: BoxDecoration(
        color: context.colors.backgroundBase,
        borderRadius: BorderRadius.circular(context.radius.r8),
        border: Border.all(
          color: context.colors.borderPrimary,
          width: context.borderWidth.w1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Non-expandable section - Orchestrator
          Section(
            isDisabled: true,
            label: 'Orchestrator',
            icon: HugeIcons.strokeRoundedSettings01,
            isSelected: _selectedSection == 'Orchestrator',
            onTap: () {
              setState(() {
                _selectedSection = 'Orchestrator';
                _selectedChild = null;
              });
            },
          ),
          SizedBox(height: context.spacing.s8),

          // Expandable section - Agent Registry
          Section(
            isDisabled: true,
            label: 'Agent Registry',
            icon: HugeIcons.strokeRoundedBook01,
            selectedChild: _selectedChild,
            onChildTap: (childLabel) {
              setState(() {
                _selectedSection = 'Agent Registry';
                _selectedChild = childLabel;
              });
            },
            children: const [
              SectionItem(label: 'For You'),
              SectionItem(label: 'Your Agents'),
              SectionItem(label: 'Add Agent'),
            ],
          ),
          SizedBox(height: context.spacing.s8),

          // Non-expandable section - Observability
          Section(
            label: 'Observability',
            icon: HugeIcons.strokeRoundedVision,
            isSelected: _selectedSection == 'Observability',
            onTap: () {
              setState(() {
                _selectedSection = 'Observability';
                _selectedChild = null;
              });
            },
          ),
          SizedBox(height: context.spacing.s8),

          // Non-expandable section - Operations
          Section(
            label: 'Operations',
            icon: HugeIcons.strokeRoundedBuilding01,
            isSelected: _selectedSection == 'Operations',
            onTap: () {
              setState(() {
                _selectedSection = 'Operations';
                _selectedChild = null;
              });
            },
          ),
          SizedBox(height: context.spacing.s8),

          // Expandable section - Recent Sessions
          Section(
            label: 'Recent Sessions',
            icon: HugeIcons.strokeRoundedWorkHistory,
            selectedChild: _selectedChild,
            onChildTap: (childLabel) {
              setState(() {
                _selectedSection = 'Recent Sessions';
                _selectedChild = childLabel;
              });
            },
            children: const [
              SectionItem(label: 'Session 1'),
              SectionItem(label: 'Session 2'),
              SectionItem(label: 'Session 3'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipExample extends StatefulWidget {
  const _ChipExample();

  @override
  State<_ChipExample> createState() => _ChipExampleState();
}

class _ChipExampleState extends State<_ChipExample> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Large Chips ---
        Text(
          'Large Chips',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s8,
          runSpacing: context.spacing.s8,
          children: [
            // Neutral variant
            NasikoChip(
              label: 'Neutral',
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.neutral,
            ),
            NasikoChip(
              label: 'With Icon',
              leadingIcon: HugeIcons.strokeRoundedStar,
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.neutral,
            ),
            NasikoChip(
              label: 'Actionable',
              leadingIcon: HugeIcons.strokeRoundedFavourite,
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.neutral,
              onTap: () {},
            ),
            NasikoChip(
              label: 'Deletable',
              leadingIcon: HugeIcons.strokeRoundedBookmark02,
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.neutral,
              onDelete: () {},
            ),
            // Brand variant
            NasikoChip(
              label: 'Brand',
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.brand,
            ),
            NasikoChip(
              label: 'Brand Selected',
              leadingIcon: HugeIcons.strokeRoundedCircleLockCheck01,
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.brand,
            ),
            NasikoChip(
              label: 'Brand Deletable',
              leadingIcon: HugeIcons.strokeRoundedSaleTag02,
              size: NasikoChipSize.large,
              variant: NasikoChipVariant.brand,
              onDelete: () {},
            ),
            // Disabled
            NasikoChip(
              label: 'Disabled',
              leadingIcon: HugeIcons.strokeRoundedUnavailable,
              size: NasikoChipSize.large,
              enabled: false,
            ),
            NasikoChip(
              label: 'Rounded',
              leadingIcon: HugeIcons.strokeRoundedCalendar03,
              size: NasikoChipSize.large,
              shape: NasikoChipShape.rounded,
            ),
          ],
        ),
        SizedBox(height: context.spacing.s24),

        // --- Small Chips ---
        Text(
          'Small Chips',
          style: context.typography.bodyPrimary.copyWith(
            color: context.colors.foregroundPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s8,
          runSpacing: context.spacing.s8,
          children: [
            // Neutral variant
            NasikoChip(
              label: 'Neutral',
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.neutral,
            ),
            NasikoChip(
              label: 'With Icon',
              leadingIcon: HugeIcons.strokeRoundedStar,
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.neutral,
            ),
            NasikoChip(
              label: 'Actionable',
              leadingIcon: HugeIcons.strokeRoundedFavourite,
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.neutral,
              onTap: () {},
            ),
            NasikoChip(
              label: 'Deletable',
              leadingIcon: HugeIcons.strokeRoundedBookmark02,
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.neutral,
              onDelete: () {},
            ),
            // Brand variant
            NasikoChip(
              label: 'Brand',
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.brand,
            ),
            NasikoChip(
              label: 'Brand Selected',
              leadingIcon: HugeIcons.strokeRoundedCircleLockCheck01,
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.brand,
            ),
            NasikoChip(
              label: 'Brand Deletable',
              leadingIcon: HugeIcons.strokeRoundedSaleTag02,
              size: NasikoChipSize.small,
              variant: NasikoChipVariant.brand,
              onDelete: () {},
            ),
            // Disabled
            NasikoChip(
              label: 'Disabled',
              leadingIcon: HugeIcons.strokeRoundedUnavailable,
              size: NasikoChipSize.small,
              enabled: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// Showcases [NasikoInput] across both sizes and every state. Stateful so the
/// runtime states (hover, focus, live character count) are actually exercised.
class _NasikoInputExample extends StatefulWidget {
  const _NasikoInputExample();

  @override
  State<_NasikoInputExample> createState() => _NasikoInputExampleState();
}

class _NasikoInputExampleState extends State<_NasikoInputExample> {
  final TextEditingController _countController =
      TextEditingController(text: 'Hello');
  final TextEditingController _readOnlyController =
      TextEditingController(text: 'nsk_8f2a91');

  @override
  void dispose() {
    _countController.dispose();
    _readOnlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget columnForSize(NasikoInputSize size, String label) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.typography.bodyPrimaryBold),
            SizedBox(height: context.spacing.s12),

            // Default — required label, leading + trailing icon, hint.
            NasikoInput(
              size: size,
              label: 'Email',
              required: true,
              placeholder: 'you@nasiko.com',
              leadingIcon: HugeIcons.strokeRoundedMail01,
              trailingIcon: HugeIcons.strokeRoundedCancel01,
              showHint: true,
              hint: 'We will never share it.',
            ),
            SizedBox(height: context.spacing.s16),

            // Error.
            NasikoInput(
              size: size,
              label: 'Email',
              placeholder: 'you@nasiko.com',
              errorText: 'Enter a valid email address.',
              showHint: true,
            ),
            SizedBox(height: context.spacing.s16),

            // Success.
            NasikoInput(
              size: size,
              label: 'Username',
              placeholder: 'nasiko',
              isSuccess: true,
              showHint: true,
              hint: 'Available!',
            ),
            SizedBox(height: context.spacing.s16),

            // Character count (count-only row: showHint true + empty hint).
            NasikoInput(
              size: size,
              label: 'Bio',
              controller: _countController,
              placeholder: 'Tell us about yourself',
              showHint: true,
              hint: '',
              showCount: true,
              maxLength: 80,
            ),
            SizedBox(height: context.spacing.s16),

            // Read-only.
            NasikoInput(
              size: size,
              label: 'Workspace ID',
              controller: _readOnlyController,
              readOnly: true,
            ),
            SizedBox(height: context.spacing.s16),

            // Disabled.
            NasikoInput(
              size: size,
              label: 'Plan',
              placeholder: 'Enterprise',
              enabled: false,
            ),
            SizedBox(height: context.spacing.s16),

            // Password — tappable show/hide toggle in the trailing slot.
            NasikoInput(
              size: size,
              label: 'Password',
              required: true,
              placeholder: 'Enter your password',
              leadingIcon: HugeIcons.strokeRoundedLockPassword,
              obscureText: true,
              showPasswordToggle: true,
              showHint: true,
              hint: 'Must be at least 8 characters.',
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        columnForSize(NasikoInputSize.medium, 'Default (m)'),
        SizedBox(width: context.spacing.s24),
        columnForSize(NasikoInputSize.small, 'Compact (s)'),
      ],
    );
  }
}

class _NasikoSearchExample extends StatefulWidget {
  const _NasikoSearchExample();

  @override
  State<_NasikoSearchExample> createState() => _NasikoSearchExampleState();
}

class _NasikoSearchExampleState extends State<_NasikoSearchExample> {
  final TextEditingController _filledM =
      TextEditingController(text: 'Invoices');
  final TextEditingController _filledS =
      TextEditingController(text: 'Invoices');
  final TextEditingController _loadingM =
      TextEditingController(text: 'Searching…');
  final TextEditingController _loadingS =
      TextEditingController(text: 'Searching…');

  @override
  void dispose() {
    _filledM.dispose();
    _filledS.dispose();
    _loadingM.dispose();
    _loadingS.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget columnForSize(
      NasikoSearchSize size,
      String label,
      TextEditingController filled,
      TextEditingController loading,
    ) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.typography.bodyPrimaryBold),
            SizedBox(height: context.spacing.s12),

            // Default — empty placeholder.
            NasikoSearch(size: size),
            SizedBox(height: context.spacing.s16),

            // Has value — clear icon visible.
            NasikoSearch(
              size: size,
              controller: filled,
              onClear: () {},
            ),
            SizedBox(height: context.spacing.s16),

            // Loading — spinner in the trailing slot.
            NasikoSearch(size: size, controller: loading, isLoading: true),
            SizedBox(height: context.spacing.s16),

            // Disabled.
            NasikoSearch(size: size, placeholder: 'Search', enabled: false),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        columnForSize(
            NasikoSearchSize.medium, 'Default (m)', _filledM, _loadingM),
        SizedBox(width: context.spacing.s24),
        columnForSize(
            NasikoSearchSize.small, 'Compact (s)', _filledS, _loadingS),
      ],
    );
  }
}
