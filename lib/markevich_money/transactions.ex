defmodule MarkevichMoney.Transactions do
  alias MarkevichMoney.Repo

  alias MarkevichMoney.Transactions.Transaction
  alias MarkevichMoney.Transactions.TransactionCategory
  alias MarkevichMoney.Transactions.TransactionCategoryPrediction

  import Ecto.Query, only: [from: 2]

  def list_transactions do
    Transaction
    |> Repo.all()
  end

  def get_transaction!(id) do
    Transaction
    |> Repo.get!(id)
    |> Repo.preload([:transaction_category, :user])
  end

  def delete_transaction(id) do
    from(t in Transaction, where: t.id == ^id) |> Repo.delete_all()
  end

  def upsert_transaction(user_id, account, amount, issued_at) do
    lookup_hash =
      :crypto.hash(:sha, "#{user_id}-#{account}-#{amount}-#{issued_at}") |> Base.encode16()

    Repo.insert(
      %Transaction{user_id: user_id, lookup_hash: lookup_hash},
      returning: true,
      on_conflict: [set: [lookup_hash: lookup_hash]],
      conflict_target: :lookup_hash
    )
  end

  def get_categories, do: Repo.all(TransactionCategory)
  def get_category!(id), do: Repo.get(TransactionCategory, id)

  def update_transaction(%Transaction{} = transaction, attrs) do
    {:ok, _} =
      transaction
      |> Transaction.update_changeset(attrs)
      |> Repo.update()
  end

  def stats(current_user, from, to) do
    query =
      from(transaction in Transaction,
        join: user in assoc(transaction, :user),
        join: category in assoc(transaction, :transaction_category),
        where: user.id == ^current_user.id,
        where: transaction.amount < ^0,
        where: transaction.issued_at >= ^from,
        where: transaction.issued_at <= ^to,
        group_by: [category.name, category.id],
        select: {sum(transaction.amount), category.name, category.id},
        order_by: [asc: 1]
      )

    Repo.all(query)
  end

  def stats(current_user, from, to, category_id) do
    query =
      from(transaction in Transaction,
        join: user in assoc(transaction, :user),
        where: user.id == ^current_user.id,
        where: transaction.amount < ^0,
        where: transaction.issued_at >= ^from,
        where: transaction.issued_at <= ^to,
        where: transaction.transaction_category_id == ^category_id,
        select: {transaction.to, transaction.amount, transaction.issued_at},
        order_by: [asc: transaction.issued_at]
      )

    Repo.all(query)
  end

  def predict_category_id(transaction_to) do
    with query <- predict_category_query(transaction_to),
         %TransactionCategoryPrediction{} = prediction <- Repo.one(query) do
      prediction.transaction_category_id
    else
      _ -> nil
    end
  end

  def create_prediction(transaction_to, transaction_category_id) do
    %TransactionCategoryPrediction{
      prediction: transaction_to,
      transaction_category_id: transaction_category_id
    }
    |> Repo.insert!()
  end

  defp predict_category_query(transaction_to) do
    from p in TransactionCategoryPrediction,
      where: p.prediction == ^transaction_to,
      order_by: [desc: p.id],
      limit: 1
  end
end
