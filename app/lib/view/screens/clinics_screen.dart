import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/cubits/clinics_cubit.dart';
import '../../controller/cubits/locale_cubit.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/banners.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/cards.dart';

/// Nearby clinics, sorted by distance from a default KL reference point
/// (MVP fallback while device GPS integration is out of scope).
class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<ClinicsCubit>().load(lat: 3.1390, lng: 101.6869);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t('clinics', locale))),
      body: BlocBuilder<ClinicsCubit, ClinicsState>(
        builder: (context, state) {
          if (state.status == ClinicsStatus.loading || state.status == ClinicsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ClinicsStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ErrorBanner(state.errorMessage ?? AppStrings.t('errorGeneric', locale)),
                    HpPrimaryButton(label: AppStrings.t('refresh', locale), onPressed: _load),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: state.clinics.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final clinic = state.clinics[i];
                return HpCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clinic.name, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(
                        '${clinic.city}, ${clinic.state}',
                        style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                      ),
                      if (clinic.distanceKm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${clinic.distanceKm} km',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        clinic.services.join(', '),
                        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
