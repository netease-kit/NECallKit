// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.base;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.typeText;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.withClassName;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withParent;
import static androidx.test.espresso.matcher.ViewMatchers.withParentIndex;
import static androidx.test.espresso.matcher.ViewMatchers.withSubstring;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static org.hamcrest.Matchers.allOf;
import static org.hamcrest.Matchers.is;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import androidx.annotation.DrawableRes;
import androidx.annotation.IdRes;
import androidx.recyclerview.widget.RecyclerView;
import androidx.test.espresso.Espresso;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.ViewInteraction;
import androidx.test.espresso.contrib.RecyclerViewActions;
import androidx.test.espresso.contrib.RecyclerViewActions.PositionableRecyclerViewAction;
import androidx.test.espresso.matcher.BoundedMatcher;
import org.hamcrest.Description;
import org.hamcrest.Matcher;

/** 基础测试方法封装 */
@ClassRegister
public final class BaseTestUtils {

  public static ViewInteraction viewAction(@IdRes int id, final ViewAction... viewActions) {
    return onView(withId(id)).perform(viewActions);
  }

  public static ViewInteraction viewAction(
      Matcher<View> viewMatcher, final ViewAction... viewActions) {
    return onView(viewMatcher).perform(viewActions);
  }

  public static ViewInteraction inputText(@IdRes int id, String content) {
    return viewAction(id, typeText(content));
  }

  public static ViewInteraction inputText(Matcher<View> viewMatcher, String content) {
    return viewAction(viewMatcher, typeText(content));
  }

  public static ViewInteraction checkText(@IdRes int id, String content) {
    return findViewInteraction(id).check(matches(withText(content)));
  }

  public static ViewInteraction checkText(Matcher<View> viewMatcher, String content) {
    return onView(viewMatcher).check(matches(withText(content)));
  }

  public static ViewInteraction containsText(@IdRes int id, String content) {
    return findViewInteraction(id).check(matches(withSubstring(content)));
  }

  public static ViewInteraction containsText(Matcher<View> viewMatcher, String content) {
    return onView(viewMatcher).check(matches(withSubstring(content)));
  }

  public static ViewInteraction checkLocalDrawable(@IdRes int id, @DrawableRes int drawableId) {
    return findViewInteraction(id).check(matches(isAimLocalDrawable(drawableId)));
  }

  public static ViewInteraction checkLocalDrawable(
      Matcher<View> viewMatcher, @DrawableRes int drawableId) {
    return onView(viewMatcher).check(matches(isAimLocalDrawable(drawableId)));
  }

  public static ViewInteraction viewClick(@IdRes int id) {
    return viewAction(id, click());
  }

  public static ViewInteraction viewClick(Matcher<View> viewMatcher) {
    return viewAction(viewMatcher, click());
  }

  public static Matcher<View> findViewMatcherInGroup(
      @IdRes int parentId, String childTypeClassName, int index) {
    return allOf(
        withParent(withId(parentId)),
        withClassName(is(childTypeClassName)),
        withParentIndex(index));
  }

  public static ViewInteraction findViewInteraction(@IdRes int id) {
    return onView(withId(id));
  }

  public static ViewInteraction findViewInteractionInGroup(
      @IdRes int parentId, String childTypeClassName, int index) {
    return onView(findViewMatcherInGroup(parentId, childTypeClassName, index));
  }

  public static <T extends RecyclerView.ViewHolder> ViewInteraction actionOnRecyclerItemWithHolder(
      @IdRes int recyclerViewId, Matcher<T> holderMatcher, final ViewAction action) {
    return viewAction(recyclerViewId, actionOnHolderItem(holderMatcher, action));
  }

  public static <T extends RecyclerView.ViewHolder> ViewInteraction clickOnRecyclerItemWithHolder(
      @IdRes int recyclerViewId, Matcher<T> holderMatcher) {
    return viewAction(recyclerViewId, actionOnHolderItem(holderMatcher, click()));
  }

  public static ViewInteraction actionOnRecyclerItemWithPosition(
      @IdRes int recyclerViewId, int position, final ViewAction action) {
    return viewAction(recyclerViewId, actionOnItemAtPosition(position, action));
  }

  public static ViewInteraction clickOnRecyclerItemWithPosition(
      @IdRes int recyclerViewId, int position) {
    return viewAction(recyclerViewId, actionOnItemAtPosition(position, click()));
  }

  public static <T extends RecyclerView.ViewHolder>
      PositionableRecyclerViewAction actionOnHolderItem(
          Matcher<T> holderMatcher, ViewAction action) {
    return RecyclerViewActions.actionOnHolderItem(holderMatcher, action);
  }

  public static ViewAction actionOnItemAtPosition(int position, ViewAction action) {
    return RecyclerViewActions.actionOnItemAtPosition(position, action);
  }

  public static void waitForTime(long millis) {
    try {
      Thread.sleep(millis);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

  public static void pressBack() {
    Espresso.pressBack();
  }

  public static BoundedMatcher<View, ImageView> isAimLocalDrawable(@DrawableRes int id) {
    return new BoundedMatcher<View, ImageView>(ImageView.class) {
      @Override
      protected boolean matchesSafely(ImageView item) {
        if (item == null) {
          return false;
        }
        Context context = item.getContext();
        if (context == null) {
          return false;
        }
        return item.getDrawable().getCurrent().getConstantState()
            == context.getResources().getDrawable(id).getConstantState();
      }

      @Override
      public void describeTo(Description description) {
        description.appendText("is same drawable");
      }
    };
  }
}
