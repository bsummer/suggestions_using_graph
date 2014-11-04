$(function(){
  $('#product-image-thumbnails map').click(function(){
    // Track GA event. Note: product is a global var that will already be defined on each PDP
    modcloth.analytics.ga.trackUserEvent(['user_actions', 'alternate_shot_video', product.id]);
  });
});
