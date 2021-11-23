defmodule TqmWeb.NavbarComponent do
  use TqmWeb, :live_component

  def render(assigns) do
    ~H"""
    <header class="bg-green-500 text-white pt-6 md:py-6">
      <div class="container md:flex md:items-center md:justify-between mx-auto px-4">
        <h1 class="md-4 md:mb-0 text-2xl">Logo Type</h1>
        <ul class="md:flex items-center list-reset text-xl">
          <li class="border-t md:border-0 md:ml-4">
            <a class="block md:inline no-underline py-4 md:py-0 text-white hover:text-gray-200" href="#">About</a>
          </li>
          <li class="border-t md:border-0 md:ml-4">
            <a class="block md:inline no-underline py-4 md:py-0 text-white hover:text-gray-200" href="#">Blog</a>
          </li>
          <li class="border-t md:border-0 md:ml-4">
            <a class="block md:inline no-underline py-4 md:py-0 text-white hover:text-gray-200" href="#">Contact</a>
          </li>
        </ul>
      </div>
    </header>
    """
  end
end
