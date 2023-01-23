class ApiResponse<T> {
  Status status;
  T? data;
  String? message;

  ApiResponse.initial(this.message) : status = Status.INITIAL;

  ApiResponse.loading(this.message) : status = Status.LOADING;

  ApiResponse.empty(this.message) : status = Status.NOTFOUND;

  ApiResponse.completed(this.data) : status = Status.COMPLETED;

  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { INITIAL, LOADING, NOTFOUND, COMPLETED, ERROR }
