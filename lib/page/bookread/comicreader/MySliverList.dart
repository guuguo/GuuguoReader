import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class MySliverList extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children in a linear array.
  const MySliverList({
    key,
    required delegate,
  }) : super(key: key, delegate: delegate);

  @override
  SliverMultiBoxAdaptorElement createElement() => SliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);

  @override
  MyRenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return MyRenderSliverList(childManager: element);
  }
}
/**参考 [RenderSliverList]*/
class MyRenderSliverList extends RenderSliverMultiBoxAdaptor {
  /// The [childManager] argument must not be null.
  MyRenderSliverList({
    required RenderSliverBoxChildManager childManager,
  }) : super(childManager: childManager);

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    if (firstChild == null) {
      if (!addInitialChild()) {
        // There are no children.
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }
    firstChild?.layout(constraints, parentUsesSize: true);

    final BoxConstraints childConstraints = constraints.asBoxConstraints();
    var child=insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
    final SliverMultiBoxAdaptorParentData childParentData = firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
    // childParentData
  }
}
