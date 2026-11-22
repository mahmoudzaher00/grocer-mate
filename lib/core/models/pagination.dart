//
// class Pagination {
//   Pagination({
//     this.total,
//     this.count,
//     this.perPage,
//     this.nextPageUrl,
//     this.prevPageUrl,
//     this.currentPage = 1,
//     this.totalPages,
//     this.querySearch = '',
//     this.isPaginated = true,
//     this.viewType,
//     this.viewTypeId,
//     this.isCompleted,
//     this.viewOption,
//   });
//
//   factory Pagination.fromJson(Map<String, dynamic> json) {
//     final data = _extractDataNode(json);
//     final pagination = _extractPaginationNode(data);
//     final items = _extractItems(data);
//
//     return Pagination(
//       total:
//           pagination.readInt(
//             keys: const <String>['totalCount', 'total', 'TotalCount', 'Total'],
//           ) ??
//           0,
//       count:
//           pagination.readInt(keys: const <String>['count', 'Count']) ??
//           items.length,
//       perPage:
//           pagination.readInt(
//             keys: const <String>['pageSize', 'per_page', 'PageSize', 'PerPage'],
//           ) ??
//           items.length,
//       nextPageUrl: pagination.readString(
//         keys: const <String>['next_page_url', 'nextPageUrl'],
//       ),
//       prevPageUrl: pagination.readString(
//         keys: const <String>['prev_page_url', 'prevPageUrl'],
//       ),
//       currentPage:
//           pagination.readInt(
//             keys: const <String>['pageNumber', 'current_page', 'CurrentPage'],
//           ) ??
//           1,
//       totalPages:
//           pagination.readInt(
//             keys: const <String>['totalPages', 'total_pages', 'TotalPages'],
//           ) ??
//           0,
//     );
//   }
//
//   final int? total;
//   final int? count;
//   final int? perPage;
//
//   //data
//   String? nextPageUrl;
//   String? prevPageUrl;
//   int currentPage;
//   int? totalPages;
//   String? querySearch;
//   bool isPaginated;
//   int? viewType;
//   String? viewTypeId;
//   bool? isCompleted;
//   int? viewOption;
//
//   int get resolvedTotalPages {
//     final pages = totalPages ?? 0;
//     return pages > 0 ? pages : (currentPage > 0 ? currentPage : 1);
//   }
//
//   // to load the next page
//   Map<String, dynamic> toNextPageParams() {
//     final Map<String, dynamic> form = {
//       if (querySearch == null || querySearch!.isEmpty)
//         'pageNumber': currentPage,
//       if (querySearch != null && querySearch!.isNotEmpty) 'search': querySearch,
//     };
//     return form;
//   }
//
//   @override
//   String toString() {
//     return 'Pagination{total: $total, count: $count, perPage: $perPage, nextPageUrl: $nextPageUrl, prevPageUrl: $prevPageUrl, currentPage: $currentPage, totalPages: $totalPages, querySearch: $querySearch, isPaginated: $isPaginated, viewType: $viewType, viewTypeId: $viewTypeId, isCompleted: $isCompleted, viewOption: $viewOption}';
//   }
// }
//
// class PaginatedResponse<T> extends Pagination {
//   PaginatedResponse({
//     super.total,
//     super.count,
//     super.perPage,
//     super.nextPageUrl,
//     super.prevPageUrl,
//     super.currentPage,
//     super.totalPages,
//     super.viewType,
//     super.viewTypeId,
//     super.isCompleted,
//     super.viewOption,
//     this.items,
//   });
//
//   factory PaginatedResponse.fromJson(
//     Map<String, dynamic> json,
//     T Function(Map<String, dynamic>) fromJsonT,
//   ) {
//     final data = _extractDataNode(json);
//     final pagination = _extractPaginationNode(data);
//     final items = _extractItems(data);
//
//     return PaginatedResponse(
//       total:
//           pagination.readInt(
//             keys: const <String>['totalCount', 'total', 'TotalCount', 'Total'],
//           ) ??
//           0,
//       count:
//           pagination.readInt(keys: const <String>['count', 'Count']) ??
//           items.length,
//       perPage:
//           pagination.readInt(
//             keys: const <String>['pageSize', 'per_page', 'PageSize', 'PerPage'],
//           ) ??
//           items.length,
//       nextPageUrl: pagination.readString(
//         keys: const <String>['next_page_url', 'nextPageUrl'],
//       ),
//       prevPageUrl: pagination.readString(
//         keys: const <String>['prev_page_url', 'prevPageUrl'],
//       ),
//       currentPage:
//           pagination.readInt(
//             keys: const <String>['pageNumber', 'current_page', 'CurrentPage'],
//           ) ??
//           1,
//       totalPages:
//           pagination.readInt(
//             keys: const <String>['totalPages', 'total_pages', 'TotalPages'],
//           ) ??
//           0,
//       items: items.map(fromJsonT).toList(),
//     );
//   }
//
//   final List<T>? items;
// }
//
// Map<String, dynamic> _extractDataNode(Map<String, dynamic> json) {
//   final upper = json['Data'];
//   if (upper is Map) return Map<String, dynamic>.from(upper);
//
//   final lower = json['data'];
//   if (lower is Map) return Map<String, dynamic>.from(lower);
//
//   return json;
// }
//
// Map<String, dynamic> _extractPaginationNode(Map<String, dynamic> data) {
//   final paginate = data['paginate'];
//   if (paginate is Map) return Map<String, dynamic>.from(paginate);
//   return data;
// }
//
// List<Map<String, dynamic>> _extractItems(Map<String, dynamic> data) {
//   final rawItems = data['items'] ?? data['Items'];
//   if (rawItems is! List) return const <Map<String, dynamic>>[];
//
//   return rawItems
//       .whereType<Map>()
//       .map((item) => Map<String, dynamic>.from(item))
//       .toList();
// }
