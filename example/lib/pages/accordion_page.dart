import 'package:flutter/material.dart';
import 'package:nasiko_ui/nasiko_ui.dart';

import '../gallery_icons.dart';
import '../gallery_section.dart';

class AccordionPage extends StatelessWidget {
  const AccordionPage({super.key});

  Widget _body(BuildContext context, String text) => Padding(
        padding: EdgeInsets.all(context.spacing.s8),
        child: Text(
          text,
          style: context.typography.bodySecondary.copyWith(
            color: context.colors.foregroundSecondary,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      title: 'Accordion & Section',
      description:
          'NasikoAccordion for expandable content; Section for sidebar-style '
          'expandable groups with child items, loading, and empty states.',
      children: [
        GallerySection(
          title: 'Accordion — single open',
          child: NasikoAccordion(
            items: [
              NasikoAccordionItem(
                title: 'What is Nasiko?',
                content: _body(context, 'An agent platform for teams.'),
              ),
              NasikoAccordionItem(
                title: 'How does billing work?',
                content: _body(context, 'Per seat, monthly or yearly.'),
              ),
              NasikoAccordionItem(
                title: 'Can I self-host?',
                content: _body(context, 'Enterprise plans include self-host.'),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Accordion — multiple open',
          child: NasikoAccordion(
            allowMultipleOpen: true,
            initialOpenIndices: const {0, 1},
            items: [
              NasikoAccordionItem(
                title: 'Section one',
                content: _body(context, 'Open by default.'),
              ),
              NasikoAccordionItem(
                title: 'Section two',
                content: _body(context, 'Also open by default.'),
              ),
              NasikoAccordionItem(
                title: 'Section three',
                content: _body(context, 'Closed by default.'),
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'Section — expandable with children',
          child: SizedBox(
            width: 280,
            child: Section(
              label: 'PROJECTS',
              icon: kIconFile,
              selectedChildId: 'beta',
              onChildTap: (_) {},
              children: [
                SectionItem(id: 'alpha', label: 'Alpha rollout', onTap: () {}),
                SectionItem(
                  id: 'beta',
                  label: 'Beta program',
                  subtitle: 'Selected child shows its subtitle',
                  onTap: () {},
                  menuActions: [
                    SectionItemAction(
                      label: 'Rename',
                      icon: kIconFile,
                      onTap: () {},
                    ),
                    SectionItemAction(
                      label: 'Delete',
                      icon: kIconDelete,
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
                SectionItem(id: 'gamma', label: 'Gamma cleanup', onTap: () {}),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'Section — states',
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Section(
                  label: 'SIMPLE (SELECTED)',
                  icon: kIconInbox,
                  isSelected: true,
                  onTap: () {},
                ),
                SizedBox(height: context.spacing.s8),
                Section(
                  label: 'DISABLED',
                  icon: kIconInbox,
                  isDisabled: true,
                  onTap: () {},
                ),
                SizedBox(height: context.spacing.s8),
                const Section(
                  label: 'LOADING',
                  icon: null,
                  isLoading: true,
                  children: [],
                ),
                SizedBox(height: context.spacing.s8),
                const Section(
                  label: 'EMPTY',
                  icon: null,
                  emptyMessage: 'Nothing here yet',
                  children: [],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
