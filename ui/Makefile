.PHONY: setup ui build test fix lint preview clean all

setup:
	curl -fsSL https://bun.sh/install | bash
	bun install

ui:
	bun run dev

build:
	bun run build

test:
	bun run test

fix:
	bun run fix

lint:
	bun run lint

preview:
	bun run preview

clean:
	rm -rf node_modules dist

all: fix test build
