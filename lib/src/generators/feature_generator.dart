import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/generators/route_registrar.dart';
import 'package:riverflow_cli/src/templates/feature/datasource_template.dart';
import 'package:riverflow_cli/src/templates/feature/entity_template.dart';
import 'package:riverflow_cli/src/templates/feature/model_template.dart';
import 'package:riverflow_cli/src/templates/feature/providers_template.dart';
import 'package:riverflow_cli/src/templates/feature/repository_impl_template.dart';
import 'package:riverflow_cli/src/templates/feature/repository_template.dart';
import 'package:riverflow_cli/src/templates/feature/usecase_template.dart';
import 'package:riverflow_cli/src/templates/view/view_template.dart';
import 'package:riverflow_cli/src/templates/viewmodel/viewmodel_template.dart';
import 'package:riverflow_cli/src/utils/build_runner.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Generates a complete feature module with Clean Architecture layers.
class FeatureGenerator {
  const FeatureGenerator({required this.logger, this.dryRun = false});

  final CliLogger logger;
  final bool dryRun;

  Future<void> generate({
    required String moduleName,
    required String projectName,
  }) async {
    final singularName = moduleName.singular.snakeCase;
    final featureDir = p.join('lib', 'features', moduleName);

    final progress = logger.progress('Creating feature module: $moduleName');

    final files = <String, String>{
      // Domain layer
      p.join(featureDir, 'domain', 'entities', '$singularName.dart'):
          entityTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),
      p.join(
        featureDir,
        'domain',
        'repositories',
        '${singularName}_repository.dart',
      ): repositoryTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),
      p.join(
        featureDir,
        'domain',
        'usecases',
        'get_${moduleName}_usecase.dart',
      ): usecaseTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),

      // Data layer
      p.join(featureDir, 'data', 'models', '${singularName}_model.dart'):
          featureModelTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),
      p.join(
        featureDir,
        'data',
        'datasources',
        '${singularName}_remote_datasource.dart',
      ): datasourceTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),
      p.join(
        featureDir,
        'data',
        'repositories',
        '${singularName}_repository_impl.dart',
      ): repositoryImplTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),

      // Presentation — providers (DI wiring)
      p.join(
        featureDir,
        'presentation',
        'providers',
        '${singularName}_providers.dart',
      ): providersTemplate(
        projectName: projectName,
        moduleName: moduleName,
      ),

      // Presentation — viewmodels
      p.join(
        featureDir,
        'presentation',
        'viewmodels',
        '${singularName}_viewmodel.dart',
      ): viewmodelTemplate(
        projectName: projectName,
        name: singularName,
        moduleName: moduleName,
      ),

      // Presentation — views
      p.join(
        featureDir,
        'presentation',
        'views',
        '${singularName}_view.dart',
      ): viewTemplate(
        projectName: projectName,
        name: singularName,
        moduleName: moduleName,
      ),
    };

    for (final entry in files.entries) {
      await FileUtils.createFile(
        filePath: entry.key,
        content: entry.value,
        logger: logger,
        dryRun: dryRun,
      );
    }

    // Create empty widgets directory
    await FileUtils.createDirectory(
      dirPath: p.join(featureDir, 'presentation', 'widgets'),
      logger: logger,
      dryRun: dryRun,
    );

    // Auto-register route
    if (!dryRun) {
      RouteRegistrar(logger: logger).registerRoute(
        moduleName: moduleName,
        projectName: projectName,
      );
    }

    progress.complete('Feature module $moduleName created!');

    // Auto-run build_runner if configured
    if (!dryRun) {
      await BuildRunnerHelper(logger: logger).runBuild();
    }
  }
}
