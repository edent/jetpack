#!/bin/bash

function run_packages_tests {
	echo "Running \`$WP_TRAVISCI\` for Packages:"
	export WP_TRAVISCI_PACKAGES="composer phpunit"
	export PACKAGES='./packages/**/tests/php'
	for PACKAGE in $PACKAGES
	do
		if [ -d "$PACKAGE" ]; then
			cd "$PACKAGE/../.."
			export NAME=$(basename $(pwd))

			if [ ! -e tests/php/travis-can-run.sh ] || tests/php/travis-can-run.sh; then
				if [ "$DO_COVERAGE" == "true" ]; then
					composer install
					export WP_TRAVISCI_PACKAGES="phpdbg -d memory_limit=2048M -d max_execution_time=900 -qrr ./vendor/bin/phpunit --coverage-clover $TRAVIS_BUILD_DIR/coverage/packages/$NAME-clover.xml"
				fi
				echo "Running \`$WP_TRAVISCI_PACKAGES\` for package \`$NAME\` "

				if $WP_TRAVISCI_PACKAGES; then
					ls -la $TRAVIS_BUILD_DIR/coverage/packages
					# Everything is fine
					:
				else
					exit 1
				fi
			fi
			cd ../..
		fi
	done
}

function print_build_info {
	echo
	echo "--------------------------------------------"
	echo "Running \`$WP_TRAVISCI\` with:"
	echo " - $(phpunit --version)"
	echo " - WordPress branch: $WP_BRANCH"
	if [ "master" == "$WP_BRANCH" ]; then
		echo " - Because WordPress is in master branch, will also attempt to test multisite."
	fi
	echo "--------------------------------------------"
	echo
}

echo "Travis CI command: $WP_TRAVISCI"

if [ "$WP_TRAVISCI" == "phpunit" ]; then

	# Run package tests only for the latest WordPress branch, because the
	# tests are independent of the version.
	if [ "latest" == "$WP_BRANCH" ]; then
		run_packages_tests
	fi

	# Run a external-html group tests
	if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
		export WP_TRAVISCI="phpunit --group external-http"
	elif [[ "$TRAVIS_EVENT_TYPE" == "api" && ! -z $PHPUNIT_COMMAND_OVERRIDE ]]; then
		export WP_TRAVISCI="${PHPUNIT_COMMAND_OVERRIDE}"
	elif [[ "$DO_COVERAGE" == "true" && -x "$(command -v phpdbg)" ]]; then
		export WP_TRAVISCI="phpdbg -qrr $HOME/.composer/vendor/bin/phpunit --coverage-clover $TRAVIS_BUILD_DIR/coverage/backend-clover.xml"
	fi

  if [ "$LEGACY_FULL_SYNC" == "1" ]; then
    export WP_TRAVISCI="phpunit --group=legacy-full-sync"
  fi

	print_build_info

	# WP_BRANCH = master | latest | previous
	cd "/tmp/wordpress-$WP_BRANCH/src/wp-content/plugins/$PLUGIN_SLUG"

	if [ "$WP_BRANCH" == "master" ]; then
		# Test multi WP in addition to single, but only in master branch mode.
		if WP_MULTISITE=1 $WP_TRAVISCI -c tests/php.multisite.xml; then
			# Everything is fine
			:
		else
			exit 1
		fi
		:
	fi

	# Test single WP
	if $WP_TRAVISCI; then
		# Everything is fine
		:
	else
		exit 1
	fi

else
	# Run linter/tests
	if $WP_TRAVISCI; then
		# Everything is fine
		:
	else
		exit 1
	fi
fi

exit 0
