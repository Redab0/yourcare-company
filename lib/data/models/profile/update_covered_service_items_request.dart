class UpdateCoveredServiceItemsRequest {
  final List<String> serviceItemIds;

  const UpdateCoveredServiceItemsRequest(this.serviceItemIds);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'serviceItemIds': serviceItemIds,
    };
  }
}
