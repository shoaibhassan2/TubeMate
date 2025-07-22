class CommerceInfo {
  bool? advPromotable;
  bool? auctionAdInvited;
  int? brandedContentType;
  bool? withCommentFilterWords;

  CommerceInfo(
      {this.advPromotable,
      this.auctionAdInvited,
      this.brandedContentType,
      this.withCommentFilterWords});

  CommerceInfo.fromJson(Map<String, dynamic> json) {
    advPromotable = json['adv_promotable'];
    auctionAdInvited = json['auction_ad_invited'];
    brandedContentType = json['branded_content_type'];
    withCommentFilterWords = json['with_comment_filter_words'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adv_promotable'] = advPromotable;
    data['auction_ad_invited'] = auctionAdInvited;
    data['branded_content_type'] = brandedContentType;
    data['with_comment_filter_words'] = withCommentFilterWords;
    return data;
  }
}