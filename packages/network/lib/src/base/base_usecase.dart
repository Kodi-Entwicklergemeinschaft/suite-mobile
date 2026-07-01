import 'package:dartz/dartz.dart';

abstract class BaseUseCase<T, Params> {
  Future<Either<Exception, T>> call(Params params);
}

class NoParams {
  const NoParams();
}
