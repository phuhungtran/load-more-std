import 'package:flutter/material.dart';
import 'package:load_more/load_more.dart';

class DefaultLoadMoreView extends StatefulWidget {
  final LoadMoreStatus status;
  final LoadMoreDelegate delegate;
  final LoadMoreTextBuilder textBuilder;
  final Widget? loadingWidget;
  const DefaultLoadMoreView({
    Key? key,
    this.status = LoadMoreStatus.idle,
    required this.delegate,
    required this.textBuilder,
    this.loadingWidget,
  }) : super(key: key);

  @override
  DefaultLoadMoreViewState createState() => DefaultLoadMoreViewState();
}

const _defaultLoadMoreHeight = 80.0;
const _loadmoreIndicatorSize = 33.0;
const _loadMoreDelay = 16;

class DefaultLoadMoreViewState extends State<DefaultLoadMoreView> {
  LoadMoreDelegate get delegate => widget.delegate;

  @override
  Widget build(BuildContext context) {
    notify();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.status == LoadMoreStatus.fail ||
            widget.status == LoadMoreStatus.idle) {
          RetryNotify().dispatch(context);
        }
      },
      child: Container(
        // height: delegate.widgetHeight(widget.status),
        padding: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.center,
        child: delegate.buildChild(widget.status,
            builder: widget.textBuilder, loadingWidget: widget.loadingWidget),
      ),
    );
  }

  void notify() async {
    var delay = max(delegate.loadMoreDelay(), Duration(milliseconds: 16));
    await Future.delayed(delay);
    if (widget.status == LoadMoreStatus.idle) {
      BuildNotify().dispatch(context);
    }
  }

  Duration max(Duration duration, Duration duration2) {
    if (duration > duration2) {
      return duration;
    }
    return duration2;
  }
}

class BuildNotify extends Notification {}

class RetryNotify extends Notification {}

typedef DelegateBuilder<T> = T Function();

/// loadmore widget properties
abstract class LoadMoreDelegate {
  static DelegateBuilder<LoadMoreDelegate> buildWidget =
      () => DefaultLoadMoreDelegate();

  const LoadMoreDelegate();

  /// the loadmore widget height
  double widgetHeight(LoadMoreStatus status) => _defaultLoadMoreHeight;

  /// build loadmore delay
  Duration loadMoreDelay() => Duration(milliseconds: _loadMoreDelay);

  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english,
      Widget? loadingWidget});
}

class DefaultLoadMoreDelegate extends LoadMoreDelegate {
  const DefaultLoadMoreDelegate();

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english,
      Widget? loadingWidget}) {
    String text = builder(status);
    // if (status == LoadMoreStatus.fail) {
    //   return Container(
    //     child: Text(text),
    //   );
    // }
    // if (status == LoadMoreStatus.idle) {
    //   return Text(text);
    // }
    if (status == LoadMoreStatus.loading) {
      if (loadingWidget != null) return loadingWidget;
      return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: _loadmoreIndicatorSize,
              height: _loadmoreIndicatorSize,
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text),
            ),
          ],
        ),
      );
    }
    // if (status == LoadMoreStatus.nomore) {
    //   return Text(text);
    // }

    return const SizedBox.shrink();
  }
}

typedef LoadMoreTextBuilder = String Function(LoadMoreStatus status);

String _buildEnglishText(LoadMoreStatus status) {
  String text;
  switch (status) {
    case LoadMoreStatus.fail:
      text = "load fail, tap to retry";
      break;
    case LoadMoreStatus.idle:
      text = "wait for loading";
      break;
    case LoadMoreStatus.loading:
      text = "loading, wait for moment ...";
      break;
    case LoadMoreStatus.nomore:
      text = "no more data";
      break;
    default:
      text = "";
  }
  return text;
}

String _buildVietnameseText(LoadMoreStatus status) {
  String text;
  switch (status) {
    case LoadMoreStatus.fail:
      text = "t???i th???t b???i, nh???n ????? th??? l???i";
      break;
    case LoadMoreStatus.idle:
      text = "?????i ????? t???i";
      break;
    case LoadMoreStatus.loading:
      text = "??ang t???i...";
      break;
    case LoadMoreStatus.nomore:
      text = "h???t d??? li???u m???i";
      break;
    default:
      text = "";
  }
  return text;
}

class DefaultLoadMoreTextBuilder {
  static const LoadMoreTextBuilder english = _buildEnglishText;

  static const LoadMoreTextBuilder vietnamese = _buildVietnameseText;
}
