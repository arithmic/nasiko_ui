import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

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

  bool _isSwitchActive = true;

  @override
  Widget build(BuildContext context) {
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
        isSwitchActive: _isSwitchActive,
        onSwitchToggled: (value) {
          setState(() {
            _isSwitchActive = value;
          });
        },
      ),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  final VoidCallback onThemeToggle;

  final bool isSwitchActive;
  final ValueChanged<bool> onSwitchToggled;

  const ExampleHomePage({
    required this.onThemeToggle,
    required this.isSwitchActive,
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
        child: Padding(
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
                title: 'Primary Buttons',
                child: _buildPrimaryButtonsExample(context),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Secondary Buttons',
                child: _buildSecondaryButtonsExample(context),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Primary Text Buttons',
                child: _buildPrimaryTextButtonsExample(context),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Secondary Text Buttons',
                child: _buildSecondaryTextButtonsExample(context),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Primary Icon Buttons',
                child: _buildPrimaryIconButtonsExample(context),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Secondary Icon Buttons',
                child: _buildSecondaryIconButtonsExample(context),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Interactive Components',
                child: _buildComponentsExample(context),
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
                title: 'Menu',
                child: const _MenuExample(),
              ),
              SizedBox(height: context.spacing.s28),
              _buildSection(
                context,
                title: 'Tab Bar',
                child: _buildTabBarExample(context),
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
            ],
          ),
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
        _buildIconSizeTile(context, 's', context.iconSize.s),
        _buildIconSizeTile(context, 'm', context.iconSize.m),
        _buildIconSizeTile(context, 'l', context.iconSize.l),
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

  Widget _buildPrimaryButtonsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large buttons
        Text('Large', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            PrimaryButton(
              size: NasikoButtonSize.large,
              onPressed: () {},
              label: 'Button',
            ),
            PrimaryButton(
              size: NasikoButtonSize.large,
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            PrimaryButton(
              size: NasikoButtonSize.large,
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.arrow_forward,
            ),
            PrimaryButton(
              size: NasikoButtonSize.large,
              onPressed: null,
              label: 'Disabled',
            ),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        // Medium buttons
        Text('Medium', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            PrimaryButton(
              size: NasikoButtonSize.medium,
              onPressed: () {},
              label: 'Button',
            ),
            PrimaryButton(
              size: NasikoButtonSize.medium,
              onPressed: () {},
              label: 'Try Orchestrator',
              leadingIcon: Icons.check,
            ),
            PrimaryButton(
              size: NasikoButtonSize.medium,
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.arrow_forward,
            ),
            PrimaryButton(
              size: NasikoButtonSize.medium,
              onPressed: null,
              label: 'Disabled',
            ),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        // Small buttons
        Text('Small', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            PrimaryButton(
              size: NasikoButtonSize.small,
              onPressed: () {},
              label: 'Button',
            ),
            PrimaryButton(
              size: NasikoButtonSize.small,
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            PrimaryButton(
              size: NasikoButtonSize.small,
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.arrow_forward,
            ),
            PrimaryButton(
              size: NasikoButtonSize.small,
              onPressed: null,
              label: 'Disabled',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryButtonsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large buttons
        Text('Large', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            SecondaryButton(
              size: NasikoButtonSize.large,
              onPressed: () {},
              label: 'Button',
            ),
            SecondaryButton(
              size: NasikoButtonSize.large,
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            SecondaryButton(
              size: NasikoButtonSize.large,
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.arrow_forward,
            ),
            SecondaryButton(
              size: NasikoButtonSize.large,
              onPressed: null,
              label: 'Disabled',
            ),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        // Medium buttons
        Text('Medium', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            SecondaryButton(
              size: NasikoButtonSize.medium,
              onPressed: () {},
              label: 'Button',
            ),
            SecondaryButton(
              size: NasikoButtonSize.medium,
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            SecondaryButton(
              size: NasikoButtonSize.medium,
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.arrow_forward,
            ),
            SecondaryButton(
              size: NasikoButtonSize.medium,
              onPressed: null,
              label: 'Disabled',
            ),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        // Small buttons
        Text('Small', style: context.typography.bodyPrimaryBold),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            SecondaryButton(
              size: NasikoButtonSize.small,
              onPressed: () {},
              label: 'Button',
            ),
            SecondaryButton(
              size: NasikoButtonSize.small,
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            SecondaryButton(
              size: NasikoButtonSize.small,
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.arrow_forward,
            ),
            SecondaryButton(
              size: NasikoButtonSize.small,
              onPressed: null,
              label: 'Disabled',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryTextButtonsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Default state
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            PrimaryTextButton(onPressed: () {}, label: 'Button'),
            PrimaryTextButton(
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            PrimaryTextButton(
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.info,
            ),
            PrimaryTextButton(onPressed: null, label: 'Disabled'),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryTextButtonsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Default state
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            SecondaryTextButton(onPressed: () {}, label: 'Button'),
            SecondaryTextButton(
              onPressed: () {},
              label: 'Button',
              leadingIcon: Icons.check,
            ),
            SecondaryTextButton(
              onPressed: () {},
              label: 'Button',
              trailingIcon: Icons.info,
            ),
            SecondaryTextButton(onPressed: null, label: 'Disabled'),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryIconButtonsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Large',
          style: context.typography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            PrimaryIconButton(
              icon: Icons.star,
              onPressed: () {},
              size: NasikoButtonSize.large,
            ),
            PrimaryIconButton(
              icon: Icons.star,
              onPressed: null,
              size: NasikoButtonSize.large,
            ),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        Text(
          'Small',
          style: context.typography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            PrimaryIconButton(
              icon: Icons.star,
              onPressed: () {},
              size: NasikoButtonSize.small,
            ),
            PrimaryIconButton(
              icon: Icons.star,
              onPressed: null,
              size: NasikoButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryIconButtonsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Large',
          style: context.typography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            SecondaryIconButton(
              icon: Icons.star,
              onPressed: () {},
              size: NasikoButtonSize.large,
            ),
            SecondaryIconButton(
              icon: Icons.star,
              onPressed: null,
              size: NasikoButtonSize.large,
            ),
          ],
        ),
        SizedBox(height: context.spacing.s20),
        Text(
          'Small',
          style: context.typography.bodyPrimary.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Wrap(
          spacing: context.spacing.s12,
          runSpacing: context.spacing.s12,
          children: [
            SecondaryIconButton(
              icon: Icons.star,
              onPressed: () {},
              size: NasikoButtonSize.small,
            ),
            SecondaryIconButton(
              icon: Icons.star,
              onPressed: null,
              size: NasikoButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.backgroundBrand,
            foregroundColor: context.colors.foregroundPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.s16,
              vertical: context.spacing.s12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.radius.r8),
            ),
          ),
          onPressed: () {},
          child: Text(
            'Primary Button',
            style: context.typography.buttonPrimary,
          ),
        ),
        SizedBox(height: context.spacing.s16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: context.colors.borderPrimary,
              width: context.borderWidth.w1,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.s16,
              vertical: context.spacing.s12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.radius.r8),
            ),
          ),
          onPressed: () {},
          child: Text(
            'Secondary Button',
            style: context.typography.buttonSecondary.copyWith(
              color: context.colors.foregroundPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldsExample(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NasikoInputField(
          label: 'Label',
          labelInfoIcon: Icons.help_outline,
          hintText: 'Email',
          helperText: 'Hint',
          leadingIcon: Icons.email_outlined,
          trailingIcon: Icons.info_outline,
          onChanged: (value) {
            // Handle change
          },
        ),
        SizedBox(height: context.spacing.s16),
        NasikoInputField(
          label: 'Password',
          hintText: 'Enter your password',
          helperText: 'Must be 8 characters.',
          leadingIcon: Icons.lock_outline,
          obscureText: true,
          onChanged: (value) {
            // Handle change
          },
        ),
      ],
    );
  }

  Widget _buildTabBarExample(BuildContext context) {
    final List<NasikoTabItem> tabs = [
      const NasikoTabItem(label: 'Trace', icon: Icons.timeline),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
      const NasikoTabItem(label: 'Trace', icon: Icons.gesture),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NasikoTabBar(tabs: tabs),

          Container(
            height: 100,
            margin: EdgeInsets.only(top: context.spacing.s16),
            child: TabBarView(
              children: tabs.map((item) {
                return Center(
                  child: Text(
                    '${item.label} Content',
                    style: context.typography.bodyPrimary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
            PrimaryButton(
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
              icon: Icons.sentiment_satisfied_alt_outlined,
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
              icon: Icons.sentiment_satisfied_alt_outlined,
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
              icon: Icons.sentiment_satisfied_alt_outlined,
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
          bannerIcon: bannerImage,
          content: content,
          onClose: () {
            debugPrint('Horizontal Banner closed');
          },
          action: PrimaryButton(
            onPressed: () {},
            label: 'Add Agent',
            size: NasikoButtonSize.small,
            trailingIcon: Icons.info_outline,
          ),
        ),

        SizedBox(height: context.spacing.s16),

        // --- Vertical Banner ---
        NasikoBanner(
          title: 'Add Agent',
          bannerIcon: bannerImage,
          content: content,
          bannerType: NasikoBannerType.vertical,
          onClose: () {
            debugPrint('Vertical Banner closed');
          },
          action: PrimaryButton(
            onPressed: () {},
            label: 'Button',
            size: NasikoButtonSize.small,
            leadingIcon: Icons.star_border,
            trailingIcon: Icons.info_outline,
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
        PrimaryButton(
          label: 'Show Confirmation',
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Confirm Operation',
              content: Text(
                'Are you sure you want to proceed with this action? It cannot be undone.',
                style: context.typography.bodyPrimary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
              primaryButtonLabel: 'Confirm',
              secondaryButtonLabel: 'Cancel',
              onPrimaryAction: () {
                Navigator.of(context).pop();
                // Perform the confirmation action here
              },
            );
          },
        ),
        SizedBox(width: context.spacing.s16),

        PrimaryButton(
          label: 'Show Alert',
          onPressed: () {
            showNasikoModal(
              context: context,
              title: 'Action Failed',
              leadingIcon: Icons.warning_rounded,
              content: Text(
                'The requested operation failed due to a server error. Please try again later.',
                style: context.typography.bodyPrimary.copyWith(
                  color: context.colors.foregroundSecondary,
                ),
              ),
              primaryButtonLabel: 'Dismiss',
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
        PrimaryButton(
          label: 'Show Success Toast',
          onPressed: () => NasikoToastService.showSuccess(
            context,
            'Operation successful! Your settings have been saved and applied.',
          ),
        ),
        PrimaryButton(
          label: 'Show Error Toast',
          onPressed: () => NasikoToastService.showError(
            context,
            'Failed to load resource. Check your network connection.',
          ),
        ),
        PrimaryButton(
          label: 'Show Warning Toast',
          onPressed: () => NasikoToastService.show(
            context,
            message: 'Data migration in progress. Do not refresh this page.',
            type: NasikoToastType.warning,
          ),
        ),
        PrimaryButton(
          label: 'Show Info Toast',
          onPressed: () => NasikoToastService.show(
            context,
            message: 'The new feature roadmap is now available for review.',
            type: NasikoToastType.info,
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
        // Row 1: Active/Inactive Switch
        Text('Interactive Switch', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        Row(
          children: [
            // This uses the 'isSwitchActive' state passed from the parent StatefulWidget
            NasikoSwitch(
              value: isSwitchActive,
              // This calls the 'onSwitchToggled' function, which executes setState in the parent
              onChanged: onSwitchToggled,
            ),
            SizedBox(width: spacing.s16),
            Text(
              isSwitchActive ? 'ON (Active)' : 'OFF (Inactive)',
              style: typography.bodyPrimary.copyWith(
                color: isSwitchActive
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
        NasikoSwitch(value: false, onChanged: null),

        // --- Separator ---
        SizedBox(height: spacing.s24),

        // Row 3: Disabled Switch
        Text('Disabled Switch (Value ON)', style: typography.bodyPrimaryBold),
        SizedBox(height: spacing.s12),
        // Disabled Switch (Value is ON, onChanged is null)
        NasikoSwitch(value: true, onChanged: null),
      ],
    );
  }
}

class _MenuExample extends StatefulWidget {
  const _MenuExample();

  @override
  State<_MenuExample> createState() => _MenuExampleState();
}

class _MenuExampleState extends State<_MenuExample> {
  // This list can be as long as you want
  final List<String> _menuItems = [
    'Label 1',
    'Label 2',
    'Label 3',
    'Label 4',
    'Label 5',
    'Label 6',
    'Label 7',
    'Label 8',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NasikoMenu(
      title: 'Menu',
      titleIcon: Icons.menu_open_outlined, // Example icon
      items: _menuItems,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
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
          leadingIcon: Icons.hexagon_outlined,
          badgeLabel: '1.85s',
          badgeIcon: Icons.check_circle_outline,
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
            leadingIcon: Icons.hexagon_outlined,
            badgeLabel: '1.85s',
            badgeIcon: Icons.check_circle_outline,
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
            leadingIcon: Icons.hexagon_outlined,
            badgeLabel: '1.85s',
            badgeIcon: Icons.check_circle_outline,
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
            leadingIcon: Icons.hexagon_outlined,
            badgeLabel: '1.85s',
            badgeIcon: Icons.check_circle_outline,

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
            label: 'Orchestrator',
            icon: Icons.settings,
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
            label: 'Agent Registry',
            icon: Icons.book,
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
            icon: Icons.visibility,
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
            icon: Icons.build,
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
            icon: Icons.history,
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
