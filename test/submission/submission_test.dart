// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> main() async {
  Stream<Submission> submissionsHelper(SubredditRef subreddit) {
    return subreddit.newest().map<Submission>((u) => u as Submission);
  }

  test('lib/submission/crosspost', () async {
    final reddit = await createRedditTestInstance(
      'test/submission/lib_submission_crosspost.json',
    );
    final subreddit = await reddit.subreddit('drawapitesting').populate();
    final originalSubmission = await reddit
        .submission(
            url:
                'https://www.reddit.com/r/tf2/comments/7919oe/greetings_from_banana_bay/')
        .populate();
    await originalSubmission.crosspost(subreddit,
        title: 'r/tf2 crosspost'
            ' test');
  });

  test('lib/submission/idFromUrl', () {
    final urls = [
      'http://my.it/2gmzqe/',
      'https://redd.it/2gmzqe/',
      'http://reddit.com/comments/2gmzqe/',
      'https://www.reddit.com/r/redditdev/comments/2gmzqe/'
          'praw_https_enabled_praw_testing_needed/'
    ];
    for (final url in urls) {
      expect(SubmissionRef.idFromUrl(url), equals('2gmzqe'));
    }
  });

  test('lib/submission/hide-unhide', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_hide_unhide.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submission = await submissionsHelper(subreddit).first;
    expect(submission.hidden, isFalse);
    await submission.hide();
    await submission.refresh();
    expect(submission.hidden, isTrue);
    await submission.unhide();
    await submission.refresh();
    expect(submission.hidden, isFalse);
  });

  test('lib/submission/hide-unhide-multiple', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_hide_unhide_multiple.json');
    final subreddit = reddit.subreddit('drawapitesting');
    final submissions = <Submission>[];
    await for (final submission in submissionsHelper(subreddit)) {
      submissions.add(submission);
      expect(submission.hidden, isFalse);
    }
    expect(submissions.length, equals(3));
    await submissions[0].hide(otherSubmissions: submissions.sublist(1));

    for (final submission in submissions) {
      await submission.refresh();
      expect(submission.hidden, isTrue);
    }
    await submissions[0].unhide(otherSubmissions: submissions.sublist(1));

    for (final submission in submissions) {
      await submission.refresh();
      expect(submission.hidden, isFalse);
    }
  });

  // TODO(bkonyi): We need to also check the post was
  // successful.
  test('lib/submission/reply', () async {
    final reddit = await createRedditTestInstance(
        'test/submission/lib_submission_reply.json');
    final submission = await (new SubmissionRef.withPath(reddit,
            r'https://www.reddit.com/r/drawapitesting/comments/7x6ew7/draw_using_dart_to_moderate_reddit_comments/'))
        .populate();
    await submission.reply('Woohoo!');
  });
}
