/// Base failure class to represent errors. ####################################
abstract class Failure {
  const Failure(this.errMessage);

  final String errMessage;
}

class DataFailure extends Failure {
  const DataFailure(super.errMessage);
}

class StorageFailure extends Failure {
  const StorageFailure(super.errMessage);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.errMessage);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.errMessage);
}